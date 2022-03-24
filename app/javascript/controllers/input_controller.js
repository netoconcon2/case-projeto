import AriaController from "./aria_controller";
import rangePlugin from 'flatpickr/dist/plugins/rangePlugin';
import flatpickr from "flatpickr";
import I18n from "../plugins/i18n";

export default class extends AriaController {
  static targets = ["span", "fileInput", "dateStartGroup", "submitBtn" ];

  connect = () => {
    if (this.element.contains(document.getElementById('filters-form'))) {
      this.collapseInputs();
      window.addEventListener('resize', this.collapseInputs);
      if (document.getElementById('query_date_start')) {
        this.loadFlatpickr();
        this.dateStartGroupTarget.insertAdjacentHTML("beforeend","<button type='button' tabindex='0' data-action='click->input#clearDatepicker' class='date-clear' data-clear><i class='fas fa-times' tabindex='-1'></i></button")
      }
    }
    const dropdownBtn = document.querySelector('#dropdownSelectBtn');
    if (dropdownBtn) {
      this.showSelected(dropdownBtn.closest('form'));
    }
  }

  handleChange(e) {
    this.spanTarget.innerText = e.currentTarget.value.match(/[^\\]+\.(docx|xlsx)$/)[0]
    const smallInputFile = document.querySelector('.file small');
    smallInputFile.classList.remove('ms-2');
    smallInputFile.insertAdjacentHTML('beforeend', `<i class="fas fa-times" data-action="click->input#resetInput" role="button" aria-pressed="false" tabindex="0" title="${I18n.t('javascript.reset_input')}"></i>`)
  }

  resetInput(e) {
    const smallInputFile = document.querySelector('.file small');
    smallInputFile.removeChild(e.currentTarget);
    this.fileInputTarget.value = "";
    this.spanTarget.innerText = "";
  }

  collapseInputs = () => {
    const inputStatus = document.getElementById('multiCollapse1');
    const inputDate = document.getElementById('multiCollapse2');
    const btnToggle = document.querySelector('.btn-arrows');
    const width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
    if (inputStatus && inputDate) {
      if (width / parseFloat(
        getComputedStyle(
          document.querySelector('html')
        )['font-size']
      ) < 75) {
        inputStatus.classList.remove('show');
        inputDate.classList.remove('show');
        btnToggle.classList.add('collapsed');
        btnToggle.setAttribute('aria-expanded', 'false');
      } else {
        inputStatus.classList.add('show');
        inputDate.classList.add('show');
      }
    }
  }

  checkboxBehavior = (e) => {
    const t = e.currentTarget;
    let name = t.dataset.checkboxes;
    const selectAllCheckbox = t.querySelector(`#${name}_all`);
    if (e.srcElement === selectAllCheckbox) { return; }
    name = name.split(/[-_]/);
    name.length === 1 ? name = `${name[0]}[]` : name = `${name[0]}[${name[1]}][]`;
    const checkboxes = t.querySelectorAll(`input[type="checkbox"][name="${name}"]`);
    let n = 0;
    // checking behavior from select all checkbox
    for (let i = 0; i < checkboxes.length; i++) {
      if (checkboxes[i].checked === false) {
        selectAllCheckbox.checked = false;
      } else {
        n++
      }
    }
    if (n === checkboxes.length) { selectAllCheckbox.checked = true; }
  }

  dropdownCheckbox = (e) => {
    const t = e.currentTarget;
    let name = t.dataset.checkboxes;
    const selectAllCheckbox = t.querySelector(`#${name}_all`);
    if (selectAllCheckbox) {
      this.checkboxBehavior(e);
    }
    this.showSelected(e.currentTarget);
  }

  dropdownInputFocus = (e) => {
    e.currentTarget.closest('label').style.backgroundColor = "#FCE7D1";
  }

  dropdownInputBlur = (e) => {
    e.currentTarget.closest('label').style.backgroundColor = "";
  }

  selectAll = (e) => {
    let name = e.currentTarget.id.replace(/[-_]all/, "").split(/[-_]/);
    name.length === 1 ? name = `${name[0]}[]`: name = `${name[0]}[${name[1]}][]`;
    let checkboxes = document.getElementsByName(name);
    for (let i = 0; i < checkboxes.length; i++) {
      checkboxes[i].checked = e.currentTarget.checked;
    }
  }

  unselectAll = () => {
    const checkboxes = document.getElementsByName(`docs[]`);
    for (let i = 0; i < checkboxes.length; i++) {
      checkboxes[i].checked = false;
    }
    document.getElementById('docs_all').checked = false;
  }

  loadFlatpickr = () => {
    this.fp = flatpickr("#query_date_start", {
      dateFormat: "d/m/Y",
      plugins: [new rangePlugin({ input: "#query_date_end" })],
      clickOpens: false,
      maxDate: new Date(),
      allowInput: true,
      disableMobile: true,
      allowInvalidPreload: true
    })
  }

  clearDatepicker = () => {
    this.fp.clear();
  }

  inputmaskDate = (e) => {
    e.currentTarget.value = e.currentTarget.value.replace(/\D/g, "")
      .replace(/^(3)([2-9])/, "$1")
      .replace(/^([4-9])/, "0$1")
      .replace(/(\d{2})(\d)/, "$1/$2")
      .replace(/^(\d{2})\/([2-9])/, "$1/0$2")
      .replace(/^(\d{2})\/1([3-9])/, "$1/1")
      .replace(/(\d{2})(\d)/, "$1/$2")
      .replace(/(\d{4})(\d)$/, "$1")
  }

  inputmask = (e) => {
    const maskType = e.currentTarget.dataset.inputmask;
  }

  toggleSubmit = (event) => {
    const inputChanges = [];
    event.currentTarget.querySelectorAll('input:not([type="hidden"])').forEach((input) => {
      // Check if the current checked status is different from the initial value
      const inputHasChanged = input.dataset.initialValue !== input.checked.toString();
      inputChanges.push(inputHasChanged);
    })
    // If any of the inputs has changed from the initial value, enable the submit button
    this.submitBtnTarget.disabled = !(inputChanges.includes(true))
  }

  disconnect = () => {
    window.removeEventListener('resize', this.collapseInputs);
  }
}
