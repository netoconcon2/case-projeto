import { Controller } from "stimulus";
import I18n from "../plugins/i18n";

export default class extends Controller {
  static targets = [ "original", "form", "submit" ]

  connect() {
    this.originalText = this.originalTarget.value;
  }

  translate(event) {
    event.preventDefault();
    event.stopPropagation();
    const nWords = this.originalTarget.value.split(/\s/).length;

    if (nWords < 5) {
      alert(I18n.t('alert.minimum_words'));
      return false;
    }

    if (confirm(I18n.t('alert.confirm_translation', { count: nWords }))) {
      this.formTarget.submit();
    } else {
      return false;
    }
  }
}
