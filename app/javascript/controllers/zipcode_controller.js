import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ "street", "city", "state", "neighborhood", "address" ]

	search = (e) => {
  	if (e.target.value.length == 9) {
  		const zipcode = e.target.value.replace("-", "")
			fetch(`https://api.postmon.com.br/v1/cep/${zipcode}`)
			.then(response => response.json())
			.then((data) => {
				this.streetTarget.value = data["logradouro"]
				this.cityTarget.value = data["cidade"]
				this.neighborhoodTarget.value = data["bairro"]
				this.stateTarget.value = data["estado"]
				this.addressTarget.hidden = false
			})
		}
	}
}
