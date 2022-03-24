class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  LANGUAGES = ['pt', 'en']

  POSSIBLE_LANGUAGE_PAIRS = LANGUAGES.combination(2).flat_map { |combination| [combination.join('_'), combination.reverse.join('_')] }
end
