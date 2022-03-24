import { Controller } from "stimulus"
import tooltips from 'plugins/tooltip';

export default class extends Controller {
  connect () {
    tooltips();
  }
}
