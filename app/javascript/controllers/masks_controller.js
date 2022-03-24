import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ "form", 'price' ]

  connect = () => {
    document.querySelectorAll('input').forEach(($input) => {
      if ($input.dataset.mask !== undefined) {
        if ($input.dataset.action === undefined) {
          $input.setAttribute('data-action', 'input->masks#inputmask');
        } else {
          $input.dataset.action += " input->masks#inputmask"
        }
        $input.value = this.masks($input.dataset.mask, $input.value);
      }
    })
  }

  inputmask = (e) => {
    const input = e.currentTarget;
    const field = input.dataset.mask;
    if (field !== undefined) {
      input.value = this.masks(field, input.value);
    }
  }

  masks = (type, value) => {
    switch (type) {
      case 'cnpj':
        return value
          .replace(/\D/g, '')
          .replace(/(\d{2})(\d)/, '$1.$2')
          .replace(/(\d{3})(\d)/, '$1.$2')
          .replace(/(\d{3})(\d)/, '$1/$2')
          .replace(/(\d{4})(\d)/, '$1-$2')
          .replace(/(-\d{2})\d+?$/, '$1')
        break;
      case 'phone':
        return value
          .replace(/\D/g, '')
          .replace(/(\d{2})/, '($1) ')
          .replace(/(\d{4})(\d)/, '$1-$2')
          .replace(/(\d{4})-(\d)(\d{4})/, '$1$2-$3')
          .replace(/(-\d{4})\d+?$/, '$1')
        break;
      case 'cep':
        return value
          .replace(/\D/g, '')
          .replace(/(\d{5})(\d)/, '$1-$2')
          .replace(/(-\d{3})\d+?$/, '$1')
        break;
      case 'agency':
        return value
          .replace(/(\d{4})(\d)/, '$1-$2')
          .replace(/(-\d{1})\d+?$/, '$1')
        break;
      case 'money':
        return value
          .replace(/\D/g, "")
          .replace(/^0+$/, "0,00")
          .replace(/^[0\,]*(\d)$/, "0,0$1")
          .replace(/^0*(\d{2})$/, "0,$1")
          .replace(/^0*(\d+)(\d{2})$/, "$1,$2")
          .replace(/(\d)(\d{3})(,\d{2})$/, "$1.$2$3")
          .replace(/(\d)(\d{3})(\.)/, "$1.$2$3")
          .replace(/(\d)(\d{3}\.)/g, "$1.$2")
          .replace(/(\d{3})(\d)\.(\d{2})(\d)\.(\d{2})(\d)\.(\d{2})(\d)\,(\d)\d/, "$1.$2$3.$4$5.$6$7,$8$9")
        break;
      case 'cpf':
        return value
          .replace(/\D/g, '')
          .replace(/(\d{3})(\d{3})(\d{3})(\d)/, '$1.$2.$3-$4')
          .replace(/(\d{3})(\d{3})(\d)/, '$1.$2.$3')
          .replace(/(\d{3})(\d)/, '$1.$2')
        break;
      case 'documents':
        if (value.length < 15) {
          return value
            .replace(/\D/g, '')
            .replace(/(\d{3})(\d{3})(\d{3})(\d)/, '$1.$2.$3-$4')
            .replace(/(\d{3})(\d{3})(\d)/, '$1.$2.$3')
            .replace(/(\d{3})(\d)/, '$1.$2')
        } else {
          return value
            .replace(/\D/g, '')
            .replace(/(\d{2})(\d)/, '$1.$2')
            .replace(/(\d{3})(\d)/, '$1.$2')
            .replace(/(\d{3})(\d)/, '$1/$2')
            .replace(/(\d{4})(\d)/, '$1-$2')
            .replace(/(-\d{2})\d+?$/, '$1')
        }
        break;
      case 'creditCard':
        return value
          .replace(/\D/g, '')
          .replace(/(\d{4})(\d{4})(\d{4})(\d)/, '$1 $2 $3 $4')
          .replace(/(\d{4})(\d{4})(\d)/, '$1 $2 $3')
          .replace(/(\d{4})(\d)/, '$1 $2')
        break;
      case 'numbers':
        return value
          .replace(/\D/g, '')
        break;
    }
  }
}
