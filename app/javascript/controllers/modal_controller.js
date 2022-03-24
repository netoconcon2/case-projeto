import AriaController from "./aria_controller";
import I18n from "../plugins/i18n";
import Swal from "sweetalert2";

export default class extends AriaController {
  static targets = []

  inviteUser = (e) => {
    const [response] = e.detail;
    Swal.fire({
      title: I18n.t('javascript.modal.invite.invite_user'),
      html: `<div id="invitation-modal"></div>`,
      showConfirmButton: false,
    })
    document.getElementById('invitation-modal').innerHTML = response.form;
  }

  turboModal = (e) => {
    Swal.fire({
      title: e.currentTarget.dataset.modalTitle,
      showCloseButton: true,
      showConfirmButton: false,
      html: `<turbo-frame id="${e.currentTarget.dataset.frameId}" ${e.currentTarget.dataset.frameAttributes || ''}></turbo-frame>`
    });
  }

  closeModal = (e) => {
    const currentTarget = document.getElementById(e.currentTarget.id)
    if (currentTarget.querySelector('.invalid-feedback') === null) {
      Swal.close();
    }
  }
}
