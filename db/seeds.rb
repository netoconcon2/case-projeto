return unless Rails.env.development?
puts "destroying existing users so there are no duplicates..."
User.destroy_all

puts "destroying existing plans so there are no duplicates..."
Plan.destroy_all

puts "destroying existing packages so there are no duplicates..."
Package.destroy_all

puts "destroying existing companies so there are no duplicates..."
Company.destroy_all

puts "destroying existing documents so there are no duplicates..."
Document.destroy_all

def create_chunks(document)
  original = document.original_text
  translation = document.translated_text
  original_chunks = original.split(/\n+/)
  translation_chunks = translation.split(/\n+/)
  doc_pairs = [original_chunks, translation_chunks].transpose
  text_chunks = []
  doc_pairs.each do |p|
    chunk = TextChunk.create!(original: p.first, translated: p.last, document: document, order: text_chunks.count + 1)
    text_chunks << chunk
  end
end

puts "\n"

# ========================================= ADMIN =========================================
puts "creating admin user..."
admin = User.create!(first_name: "Admin",
                     last_name: "of Decode",
                     email: "admin@admin.com",
                     password: "admin123",
                     role: 1,
                     admin: true)
# ==========================================================================================
puts "\n"
# ========================================= PLANS ==========================================
puts "creating a published plan..."
plan = Plan.create!(name: 'Published Plan',
                    pagarme_id: 1,
                    price: 2,
                    days: 30,
                    trial_days: 10,
                    charges: 1,
                    installments: 1,
                    words: 10_000,
                    status: 2)
# ==========================================================================================
puts "\n"
# ======================================== PJ USER =========================================
puts "creating a pj user..."
User.create!(first_name: "Number",
             last_name: "Five",
             email: 'numberfive@umbrella.corp',
             password: 'dolores',
             role: 2)
# ==========================================================================================
puts "\n"
# ===================================== UMBRELLA CORP ======================================
puts "creating the manager of Umbrella Corporation..."
ozwell = User.create!(first_name: "Oz",
                      last_name: "Spencer",
                      email: 'oz.spencer@umbrella.zmb',
                      password: 'brains',
                      role: 1)

puts "creating a validated Umbrella Corporation..."
u_corp = Company.create!(name: 'Umbrella Corporation',
                         owner: ozwell,
                         status: 2,
                         cnpj: "11.111.111/1111-11",
                         country: 'Himalaia',
                         street: "Lorem Ipsum street",
                         street_number: 111,
                         zip_code: "04242-424",
                         city: "Townsville",
                         state: "Somewhere",
                         phone: "(11) 96666-6666",
                         neighborhood: "Limoeiro",
                         plan: plan,
                         available_words: 10)

puts "creating an employee of Umbrella Corporation..."
james = User.create!(first_name: "James",
                     last_name: "Marcus",
                     email: 'james@umbrella.zmb',
                     password: '123123',
                     role: 3,
                     company: u_corp)
# ==========================================================================================
puts "\n"
# ======================================= ACME CORP ========================================
puts "creating the manager of ACME..."
bbunny = User.create!(first_name: "Bunny",
                      last_name: "Carrots",
                      email: 'pernalonga@acme.com',
                      password: '123123',
                      role: 1)

puts "creating a validated ACME..."
acme = Company.create!(name: 'ACME',
                       owner: bbunny,
                       status: 1,
                       cnpj: "22.222.222/2222-22",
                       country: "Australia",
                       street: "Lorem Ipsum street",
                       street_number: 111,
                       zip_code: "04242-424",
                       city: "Townsville",
                       state: "Somewhere",
                       phone: "(11) 96666-6666",
                       neighborhood: "Limoeiro")

puts "creating an employee of ACME..."
User.create!(first_name: "Wile",
             last_name: "Coyote",
             email: 'coyote@acme.com',
             password: '123123',
             role: 3,
             company: acme)
# ==========================================================================================
puts "\n"
# ==================================== TRANSLATOR CORP =====================================
puts "creating the manager of Thorin's Company..."
thorin = User.create!(first_name: "Thorin",
                      last_name: "Oakenshield",
                      email: "oakenshield@thorin.com",
                      password: "123123",
                      role: 1)

puts "creating a completed Thorin's Company..."
thorin_comp = Company.create!(name: "Thorin's Company",
                              owner: thorin,
                              status: 2,
                              cnpj: "33.333.333/3333-33",
                              country: "Middle Earth",
                              street: "Bag End",
                              street_number: 1,
                              zip_code: "11111",
                              city: "Hobbiton",
                              state: "The Shire",
                              phone: "(11) 96666-6666",
                              neighborhood: "The Hill",
                              plan: plan,
                              available_words: 10)

puts "creating an employee of Thorin's Company..."
bilbo = User.create!(first_name: "Bilbo",
                     last_name: "Baggins",
                     email: 'bilbo@thorin.com',
                     password: '123123',
                     role: 3,
                     company: thorin_comp)
# ==========================================================================================
puts "\n"
# ======================================= DOCUMENTS ========================================
puts "Creating test documents for Umbrella..."
30.times do
  Document.create!(user: [ozwell, james].sample,
                   company: u_corp,
                   title: Faker::TvShows::BojackHorseman.unique.character,
                   original_text: Faker::TvShows::BojackHorseman.quote,
                   source: Document::LANGUAGES.first,
                   target: Document::LANGUAGES.last,
                   status: (0..2).to_a.sample)
end

puts "Creating long document for Thorin's Company..."
doc = Document.create!(user: bilbo,
                       company: thorin_comp,
                       title: "Anna Karenina Chapter 1",
                       original_text: "Happy families are all alike; every unhappy family is unhappy in its own way.\n\nEverything was in confusion in the Oblonskys' house. The wife had discovered that the husband was carrying on an intrigue with a French girl, who had been a governess in their family, and she had announced to her husband that she could not go on living in the same house with him. This position of affairs had now lasted three days, and not only the husband and wife themselves, but all the members of their family and household, were painfully conscious of it. Every person in the house felt that there was so sense in their living together, and that the stray people brought together by chance in any inn had more in common with one another than they, the members of the family and household of the Oblonskys. The wife did not leave her own room, the husband had not been at home for three days. The children ran wild all over the house; the English governess quarreled with the housekeeper, and wrote to a friend asking her to look out for a new situation for her; the man-cook had walked off the day before just at dinner time; the kitchen-maid, and the coachman had given warning.\n\nThree days after the quarrel, Prince Stepan Arkadyevitch Oblonsky--Stiva, as he was called in the fashionable world-- woke up at his usual hour, that is, at eight o'clock in the morning, not in his wife's bedroom, but on the leather-covered sofa in his study. He turned over his stout, well-cared-for person on the springy sofa, as though he would sink into a long sleep again; he vigorously embraced the pillow on the other side and buried his face in it; but all at once he jumped up, sat up on the sofa, and opened his eyes.\n\n\"Yes, yes, how was it now?\" he thought, going over his dream. \"Now, how was it? To be sure! Alabin was giving a dinner at Darmstadt; no, not Darmstadt, but something American. Yes, but then, Darmstadt was in America. Yes, Alabin was giving a dinner on glass tables, and the tables sang, Il mio tesoro--not Il mio tesoro though, but something better, and there were some sort of little decanters on the table, and they were women, too,\" he remembered.\n\nStepan Arkadyevitch's eyes twinkled gaily, and he pondered with a smile. \"Yes, it was nice, very nice. There was a great deal more that was delightful, only there's no putting it into words, or even expressing it in one's thoughts awake.\" And noticing a gleam of light peeping in beside one of the serge curtains, he cheerfully dropped his feet over the edge of the sofa, and felt about with them for his slippers, a present on his last birthday, worked for him by his wife on gold-colored morocco. And, as he had done every day for the last nine years, he stretched out his hand, without getting up, towards the place where his dressing-gown always hung in his bedroom. And thereupon he suddenly remembered that he was not sleeping in his wife's room, but in his study, and why: the smile vanished from his face, he knitted his brows.\n\n\"Ah, ah, ah! Oo!...\" he muttered, recalling everything that had happened. And again every detail of his quarrel with his wife was present to his imagination, all the hopelessness of his position, and worst of all, his own fault.\n\n\"Yes, she won't forgive me, and she can't forgive me. And the most awful thing about it is that it's all my fault--all my fault, though I'm not to blame. That's the point of the whole situation,\" he reflected. \"Oh, oh, oh!\" he kept repeating in despair, as he remembered the acutely painful sensations caused him by this quarrel.\n\nMost unpleasant of all was the first minute when, on coming, happy and good-humored, from the theater, with a huge pear in his hand for his wife, he had not found his wife in the drawing-room, to his surprise had not found her in the study either, and saw her at last in her bedroom with the unlucky letter that revealed everything in her hand.\n\nShe, his Dolly, forever fussing and worrying over household details, and limited in her ideas, as he considered, was sitting perfectly still with the letter in her hand, looking at him with an expression of horror, despair, and indignation.\n\n\"What's this? this?\" she asked, pointing to the letter.\n\nAnd at this recollection, Stepan Arkadyevitch, as is so often the case, was not so much annoyed at the fact itself as at the way in which he had met his wife's words.\n\nThere happened to him at that instant what does happen to people when they are unexpectedly caught in something very disgraceful. He did not succeed in adapting his face to the position in which he was placed towards his wife by the discovery of his fault. Instead of being hurt, denying, defending himself, begging forgiveness, instead of remaining indifferent even--anything would have been better than what he did do--his face utterly involuntarily (reflex spinal action, reflected Stepan Arkadyevitch, who was fond of physiology)--utterly involuntarily assumed its habitual, good-humored, and therefore idiotic smile.\n\nThis idiotic smile he could not forgive himself. Catching sight of that smile, Dolly shuddered as though at physical pain, broke out with her characteristic heat into a flood of cruel words, and rushed out of the room. Since then she had refused to see her husband.\n\n\"It's that idiotic smile that's to blame for it all,\" thought Stepan Arkadyevitch.\n\n\"But what's to be done? What's to be done?\" he said to himself in despair, and found no answer.",
                       translated_text: "Todas as famílias felizes são parecidas, cada família infeliz é infeliz a seu próprio modo.\n\nTudo era confusão na casa dos Oblônski. A esposa descobriu que o marido tivera um caso com sua ex-governanta francesa, e informou-lhe que não podia viver na mesma casa que ele. Esta situação prolongava-se já pelo terceiro dia, fazendo-se sentir de forma aflitiva nos cônjuges, em todos os membros da família e em toda a criadagem. Todos os membros da família e da criadagem percebiam que não havia sentido em sua convivência, e que até pessoas reunidas por acaso em qualquer hospedaria estavam mais ligadas entre si do que eles, membros da família e da criadagem dos Oblônski. A mulher não saía de seu quarto, o marido não estava em casa pelo terceiro dia. As crianças corriam pela casa toda, como perdidas; a preceptora inglesa brigara com a governanta e escrevera um bilhete a uma amiga, pedindo que lhe encontrasse um novo emprego; o cozinheiro saíra da casa na véspera, exatamente na hora do jantar; a auxiliar de cozinha e o cocheiro tinham pedido as contas.\n\nNo terceiro dia após a briga, o príncipe Stepan Arkáditch Oblônski — Stiva, como o chamavam em sociedade —, na hora de costume, ou seja, às oito da manhã, não acordou no quarto da esposa, mas em seu gabinete, em um sofá de marroquim. Virou o corpo roliço e bem cuidado nas molas do sofá, como se desejasse voltar a dormir um pouco, abraçou com força o travesseiro do outro lado e apertou-o contra a face; de repente, porém, deu um salto, sentou-se no sofá e abriu os olhos.\n\n“Sim, sim, como foi?”, pensou, lembrando o sonho. “Sim, como foi? Sim! Alábin dava um jantar em Darmstadt; não, não era em Darmstadt, mas algo americano. Sim, é que no sonho Darmstadt ficava na América. Sim, Alábin dava um jantar em mesas de vidro, sim, e as mesas cantavam Il miotesoro, e não era Il mio tesoro, mas algo melhor, e havia umas garrafinhas pequenas, e elas eram mulheres”, lembrava.\n\nOs olhos de Stepan Arkáditch brilhavam, alegres, e ele ficou pensativo, sorrindo. “Sim, era bom, muito bom. Teve ainda muita coisa excelente, só que não dá para dizer com palavras, nem exprimir os pensamentos depois de acordado.” E, notando a faixa de luz que irrompia ao lado de uma das corrediças de feltro, baixou com alegria os pés do sofá, encontrou os chinelos de feltro dourado bordados pela esposa (presente de aniversário do ano anterior) e, sem se levantar, seguindo o velho hábito de nove anos, esticou a mão para o lugar do dormitório em que seu roupão ficava pendurado. Daí se lembrou, de repente, como e por que não dormira no quarto da esposa, mas no gabinete; o sorriso desapareceu de seu rosto, ele franziu a testa.\n\n“Ah, ah, ah! Aaa!...”, pôs-se a mugir, lembrando tudo que acontecera. E voltaram a surgir em sua imaginação todos os detalhes da briga com a mulher, todo o caráter inescapável de sua situação e, o mais torturante de tudo, sua própria culpa.\n\n“Sim! Ela não vai perdoar, e não pode perdoar. E o mais horrível é que a culpa é toda minha, é minha culpa, mas não sou culpado. Todo o drama está aí”, pensava. “Ah, ah, ah”, repetia, com desespero, lembrando as impressões que mais lhe pesavam daquela briga.\n\nO mais desagradável de tudo fora aquele primeiro instante em que, ao voltar do teatro, feliz e satisfeito, trazendo na mão uma pera enorme para a mulher, não a encontrara na sala de visitas; para seu espanto, tampouco a encontrara no gabinete e, finalmente, vira-a no quarto, segurando o bilhete nefasto, que tudo revelava.\n\nEla, aquela Dolly sempre preocupada, atarefada e, na opinião dele, de ideias curtas, estava sentada com o bilhete na mão, fitando-o com uma expressão de horror, desespero e ira.\n\n— O que é isso? Isso? — ela perguntava, apontando para o bilhete.\n\nComo acontece com frequência, ao se lembrar daquilo, Stepan Arkáditch não se atormentava tanto com o fato em si quanto com a resposta que dera às palavras da mulher.\n\nNaquele instante, acontecera com ele o que acontece com as pessoas colhidas inesperadamente em algo vergonhoso demais. Não conseguira preparar seu rosto à situação em que se viu, diante da esposa, após a descoberta de sua culpa. Em vez de ofender-se, renegar, justificar-se, pedir perdão, até mesmo ficar indiferente — qualquer coisa teria sido melhor do que o que ele fez! —, seu rosto, de forma completamente involuntária (reflexos do cérebro, pensou Stepan Arkáditch, que adorava fisiologia), de repente se abriu em um sorriso corriqueiro, bondoso e, por isso, estúpido.\n\nNão conseguia se perdoar por aquele sorriso estúpido. Ao ver tal sorriso, Dolly estremeceu como de uma dor física, desencadeando, como o ardor que lhe era próprio, torrentes de palavras cruéis, e saiu do quarto. Desde então não queria ver o marido.\n\n“A culpa é toda daquele sorriso estúpido”, pensou Stepan Arkáditch.\n\n“Mas o que fazer? Que fazer?”, dizia para si, desesperado, sem encontrar resposta.",
                       source: Document::LANGUAGES.last,
                       target: Document::LANGUAGES.first,
                       status: 3)

puts "Creating long document chunks..."
create_chunks(doc)

puts "Creating test documents for Thorin's Company..."
30.times do
  document = Document.new(user: [thorin, bilbo].sample,
                          company: thorin_comp,
                          title: Faker::Fantasy::Tolkien.unique.character,
                          original_text: Faker::Fantasy::Tolkien.poem,
                          source: Document::LANGUAGES.sample,
                          status: (0..2).to_a.sample)
  document.target = Document::LANGUAGES.reject { |language| language == document.source }.sample
  document.save!
end

puts "Creating translated test documents for Thorin's Company..."
15.times do
  document = Document.new(user: [thorin, bilbo].sample,
                          company: thorin_comp,
                          title: Faker::Movies::Hobbit.unique.character,
                          original_text: Faker::Fantasy::Tolkien.poem,
                          translated_text: Faker::Movies::Hobbit.quote,
                          source: Document::LANGUAGES.sample,
                          status: 3)
  document.target = Document::LANGUAGES.reject { |language| language == document.source }.sample
  document.save!
  create_chunks(document)
end
# ==========================================================================================
puts "\n"
# ======================================= GLOSSARIES =======================================
puts "Creating glossaries with terms for Thorin's Company..."
5.times do
  glossary = Glossary.new(company: thorin_comp,
                          name: Faker::Fantasy::Tolkien.location,
                          language_1: Document::LANGUAGES.sample)
  glossary.language_2 = Document::LANGUAGES.reject { |language| language == glossary.language_1 }.sample
  glossary.save!
end

# ==========================================================================================
puts "\n"
puts "All done!"
