import { Controller } from "stimulus";
import I18n from "../plugins/i18n";

export default class extends Controller {
  static targets = [ "tab", "step", "prevBtn", "nextBtn", "form" ]

  initialize() {
    // Current tab is set to be the first tab -> 0
    this.showCurrentTab(0);
  }

  nextPrev(e) {
    // if the form is valid then go to the next tab else don't
    let valid = true;
    $('[data-validate]:input:visible').each(function() {
      const settings = window[this.form.id].ClientSideValidations.settings;
      if (!$(this).isValid(settings.validators)) {
        valid = false
      }
    });
    if (valid) {
      //code to go to next step
      if (e.currentTarget.id === "nextBtn") this.index++;
    }
    if (e.currentTarget.id === "prevBtn") {
      if (this.index === 0) return;
      this.index--
    }
    // if the user reached the end of the form
    if (this.index >= this.tabTargets.length) {
      // the form will be submitted before showCurrentTab was called
      this.formTarget.submit();

      return;
    }
    this.showCurrentTab(this.index);
  }

  showCurrentTab(index) {
    this.index = index; // index who communicates with nextPrev
    this.tabTargets.forEach((el, i) => {
      el.classList.toggle("current-tab", this.index == i); // displayig the speciefied tab of the form
      $(el).closest('form[data-client-side-validations]').validate();
    })
    // Fixing Prev/Next buttons
    if (index === 0) {
      this.prevBtnTarget.style.visibility = "hidden";
      this.prevBtnTarget.disabled = true;
    } else {
      this.prevBtnTarget.disabled = false;
      this.prevBtnTarget.style.visibility = "visible";
    }
    index === (this.tabTargets.length - 1) ? this.nextBtnTarget.innerHTML = I18n.t('javascript.multistep.submit') : this.nextBtnTarget.innerHTML = I18n.t('javascript.multistep.next')
  }

  next(e) {
    if (e.keyCode == 13) {
      this.nextBtnTarget.click();
    }
  }
}
