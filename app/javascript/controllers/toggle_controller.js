import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ['option1', 'option2', 'form1', 'form2', 'toggleable', 'resetableInput', 'resetableTag'];

  switchVisible = (event) => {
    if (event.target.checked) {
      this.option1Target.classList.add('d-none');
      this.option2Target.classList.remove('d-none');
    }
    else {
      this.option1Target.classList.remove('d-none');
      this.option2Target.classList.add('d-none');
    }
  }

  deleteForm = (event) => {
    if (event.target.checked) {
      this.form1Target.value = '';
    }
    else {
      this.form2Target.value = '';
      if (this.form2Target.nextElementSibling) {
        this.form2Target.nextElementSibling.remove();
      }
    }
  }

  switchToggleable = (event) => {
    if (event.target.checked) {
      this.toggleableTarget.classList.remove('d-none');
    }
    else {
      this.toggleableTarget.classList.add('d-none');
    }
  }

  resetInputOnHide = (event) => {
    if (!event.target.checked) {
      this.resetableInputTarget.value = '';
      if (this.resetableTagTarget) {
        this.resetableTagTarget.innerText = '';
      }
    }
  }
}
