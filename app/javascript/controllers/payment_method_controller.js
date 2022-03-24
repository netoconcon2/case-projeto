import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ "creditCard", "bankSlip", "slipBtn", "cardBtn" ]

	bankSlip () {
  	this.slipBtnTarget.classList.add("active")
  	this.cardBtnTarget.classList.remove("active")
  	this.creditCardTarget.hidden = true
  	this.bankSlipTarget.hidden = false
	}

	creditCard () {
		this.slipBtnTarget.classList.remove("active")
		this.cardBtnTarget.classList.add("active")
		this.creditCardTarget.hidden = false
		this.bankSlipTarget.hidden = true
	}
}
