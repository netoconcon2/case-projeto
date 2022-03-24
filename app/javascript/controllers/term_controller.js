import { Controller } from "stimulus";

export default class extends Controller {
  connect = () => {
  }

  cancelForm = (e) => {
    const turboFrame = document.getElementById(e.currentTarget.dataset.frameTarget);
    turboFrame.innerHTML = '';
    turboFrame.removeAttribute('src');
  }
}