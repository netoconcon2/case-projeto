import AriaController from "./aria_controller";
import I18n from "../plugins/i18n";

export default class extends AriaController {
  static targets = []

  connect = () => {
    this.formPanel = document.getElementById('status-form');
    this.statusPanel = document.getElementById('statuses');
    this.mobileChange();
    window.addEventListener('resize', this.mobileChange);
    const checkboxFormDropdown = document.getElementById('status-form-dropdown');
    this.submitInput( checkboxFormDropdown ? checkboxFormDropdown : this.formPanel);
  }

  showCards = (e) => {
    const [response] = e.detail;
    document.getElementById('cards-container').innerHTML = response.plans;
  }

  submitInput = (target) => {
    Rails.fire(target, 'submit');
  }

  handleInput = (e) => {
    this.submitInput(e.currentTarget);
  }

  mobileChange = () => {
    const dropdownEnum = document.getElementById('enum-dropdown'); // enum options in dropdown form
    const width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
    if (width / parseFloat(
        getComputedStyle(
          document.querySelector('html')
        )['font-size']
      ) <= 48 && !dropdownEnum) {
      const linksHeader = document.getElementById('links-header'); // where the dropdown will be inserted
      const cbClone = this.formPanel.cloneNode(true); // a clone from the original panel to be inserted at dropdown
      // adaptations for turn into a dropdown
      const model = cbClone.dataset.checkboxes.replace(/_status/, '');
      cbClone.setAttribute('data-action', "input->tab#handleInput input->input#dropdownCheckbox ajax:success->tab#showCards");
      cbClone.setAttribute('id', "status-form-dropdown");
      cbClone.querySelector('ul').removeAttribute('aria-labelledby');
      cbClone.querySelector('ul').classList.add('dropdown-menu');
      cbClone.setAttribute('aria-labelledby', 'dropdownSelectBtn');
      cbClone.querySelectorAll('input').forEach((input) => {
        if (input.id.includes('status_all')) {
          input.setAttribute('data-action', 'focus->input#dropdownInputFocus blur->input#dropdownInputBlur input->input#selectAll')
        } else {
          input.setAttribute('data-action', 'focus->input#dropdownInputFocus blur->input#dropdownInputBlur')
        }
      })
      cbClone.insertAdjacentHTML('afterbegin', `<button id="dropdownSelectBtn" class="dropdown-toggle-button form-control" type="button" data-bs-toggle="dropdown" aria-expanded="false" aria-haspopup="true" title="${I18n.t('javascript.dropdown_select.title')}">
      </button>`);
      // inserting into DOM
      linksHeader.insertAdjacentHTML('beforeend', `
        <div id="enum-dropdown" aria-label="${I18n.t('javascript.dropdown_select.label', { model: I18n.t('activerecord.models.' + model ) })}" role="listbox" class="index-h">
        <span class="visibility-hidden">${I18n.t('javascript.dropdown_select.label', { model: I18n.t('activerecord.models.' + model ) })}</span>
        </div>
      `)
      document.getElementById('enum-dropdown').insertAdjacentElement('beforeend', cbClone);
      this.statusPanel = this.statusPanel.cloneNode(true); // cloning the panel in case it need to be inserted again
      document.getElementById('statuses').remove(); // removing the original panel
      this.showSelected(cbClone); // to show number of selected enums as placeholder
    }
    if (width / parseFloat(
        getComputedStyle(
          document.querySelector('html')
        )['font-size']
      ) > 48 && dropdownEnum) {
      dropdownEnum.remove(); // going back to desktop version, dropdown need to be removed
      document.getElementById('content-cards').insertAdjacentElement('afterbegin', this.statusPanel); // panel comes back
    }
  }

  disconnect = () => {
    window.removeEventListener('resize', this.mobileChange)
  }
}
