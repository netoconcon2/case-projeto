import { Controller } from "stimulus";

export default class AriaController extends Controller {
    static values = { url: String }

  connect = () => {
    this.autosave_timer = {};
  }

  handleInput = (e) => {
    let formTarget;
    if (e.currentTarget.tagName == 'TRIX-EDITOR') {
      const inputTarget = e.currentTarget.parentElement.querySelector('input');
      formTarget = inputTarget.form;
      inputTarget.setAttribute('value', e.currentTarget.value);
    }
    this.autosave(formTarget);
  }

  autosave = (form) => {
    const submitInput = () => { Rails.fire(form, 'submit'); }
    if (this.autosave_timer[form.id]) {
      clearTimeout(this.autosave_timer[form.id])
    }

    this.autosave_timer[form.id] = setTimeout(submitInput, 2000);
  }

  applyFormat = (e) => {
    const btn = e.currentTarget;

    const trixEditor = this.getTrixEditor();
    if (trixEditor) {
      trixEditor.editor.recordUndoEntry(`${btn.id}-${this.makeId()}`);
      if (trixEditor.editor.composition.currentAttributes[btn.id]) {
        trixEditor.editor.deactivateAttribute(btn.id);
      } else {
        trixEditor.editor.activateAttribute(btn.id);
      }
    }
  }

  makeId = () => {
    let result = '';
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    for (var i = 0; i < characters.length; i++) {
      result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result;
  }

  applyHeader = () => {
    const trixEditor = this.getTrixEditor();
    if (trixEditor) {
      const headersArr = ['heading1', 'heading2', 'heading3'];
      const editorAttributes = trixEditor.editor.composition.currentAttributes;
      const currentHeader = Object.keys(editorAttributes).find(val => val.match(/heading/));
      trixEditor.editor.recordUndoEntry(`heading-${this.makeId()}`);
      if (currentHeader) {
        trixEditor.editor.deactivateAttribute(currentHeader);
        const currentHeaderIndex = headersArr.indexOf(currentHeader);
        if (currentHeaderIndex !== headersArr.length - 1) {
          trixEditor.editor.activateAttribute(headersArr[currentHeaderIndex + 1]);
        }
      } else {
        trixEditor.editor.activateAttribute(headersArr[0]);
      }
    }
  }

  redo = () => {
    const trixEditor = this.getTrixEditor();

    if (trixEditor) { trixEditor.editor.redo(); }
  }

  undo = () => {
    const trixEditor = this.getTrixEditor();

    if (trixEditor) { trixEditor.editor.undo(); }
  }

  getTrixEditor = () => {
    if (!Element.prototype.matches) Element.prototype.matches = Element.prototype.msMatchesSelector;
    if (!Element.prototype.closest) Element.prototype.closest = function (selector) {
      let el = this;
      while (el) {
        if (el.matches(selector)) return el;
        el = el.parentElement;
      }
    };
    const selectionNode = window.getSelection().anchorNode;
    const trixEditor = selectionNode ? selectionNode.parentElement.closest('trix-editor') : null
    return trixEditor;
  }

  copyText = () => {
    if (document.querySelector('trix-editor')) {
      // Get the text from all rich text fields
      const allTrixEditors = document.querySelectorAll('trix-editor');
      const allText = [];
      allTrixEditors.forEach((trix) => allText.push(trix.textContent));

      // Sets a dummy textarea to select and put the text from the trix inside it
      const tempTextArea = document.createElement('textarea');
      document.body.appendChild(tempTextArea);
      tempTextArea.value = allText.join("\n");
      tempTextArea.select();

      // Copies the content of the temp trix to the dashboard
      document.execCommand('copy')

      // Deletes the temp trix element
      document.body.removeChild(tempTextArea);
    }

  }
}
