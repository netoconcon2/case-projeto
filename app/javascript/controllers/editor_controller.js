import { Controller } from "stimulus";
import { FetchRequest } from '@rails/request.js'
import Swal from "sweetalert2";
import I18n from "../plugins/i18n";

export default class AriaController extends Controller {
  static targets = [ 'searchForm', 'cleanBtn', 'toggleLinks' ]
  static values = { url: String, documentId: String }

  connect = () => {
    this.autosave_timer = {};
  }

  regexExpGenerator = (str, option = '') => {
    const regexString = str.replace(/[|\\{}()[\]^$+*?.]/g, '\\$&');
    return new RegExp(regexString, `${option}g`);
  }

  selectFocusedRow = (e) => {
    const target = e.currentTarget;
    this.element.querySelectorAll('.editor-table tbody').forEach((row) => {
      row.classList.remove('selected');
    })
    target.classList.add('selected');
  }

  selectRows = (e) => {
    e.preventDefault();
    const target = e.currentTarget;
    const editorTable = target.parentElement;
    const lastTarget = document.querySelector('tbody.selected');
    this.element.querySelectorAll('.chunk-highlight.terms').forEach(highlight => {
      highlight.remove();
    })
    if (!e.ctrlKey && !e.shiftKey) {
      this.element.querySelectorAll('.editor-table tbody').forEach((row) => {
        row.classList.remove('selected');
      })
      target.classList.add('selected');
    } else if (!e.ctrlKey && e.shiftKey) {
      if (window.getSelection) {window.getSelection().removeAllRanges();}
      else if (document.selection) {document.selection.empty();}
      const selectedRowIndex = Array.prototype.indexOf.call(editorTable.children, lastTarget);
      const trIndex = Array.prototype.indexOf.call(editorTable.children, target);
      if (target.classList.contains('selected')) {
        this.element.querySelectorAll('.editor-table tbody').forEach(row => {
          row.classList.remove('selected');
        })
      }
      if (selectedRowIndex > trIndex) {
        Array.from(editorTable.children).slice(trIndex, selectedRowIndex + 1).forEach((row) => {
          row.classList.add('selected');
        })
      } else if (selectedRowIndex < trIndex) {
        Array.from(editorTable.children).slice(selectedRowIndex, trIndex + 1).forEach((row) => {
          row.classList.add('selected');
        })
      }
    } else if (e.ctrlKey && !e.shiftKey) {
      if (!(document.querySelectorAll('tbody.selected').length == 1 && target == document.querySelector('tbody.selected'))) {
        target.classList.toggle('selected');
        if (!target.classList.contains('selected')) {
          target.querySelector('trix-editor').blur();
        }
      }
    }
    if (this.element.querySelectorAll('tbody.selected').length == 1) {
      const targetId = this.element.querySelector('tbody.selected').id.match(/\d+$/)[0]
      const docId = this.element.id.match(/\d+$/)[0]
      this.activateTextChunkVersions();
      this.matchingTerms(docId, targetId);
    } else {
      document.getElementById('glossaries_terms').innerHTML = '';
      this.inactivateTextChunkVersions();
    }
  }

  activateTextChunkVersions() {
    const versionsButton = document.querySelector('button#versions');
    versionsButton.disabled = false;
  };

  inactivateTextChunkVersions() {
    const versionsButton = document.querySelector('button#versions');
    versionsButton.disabled = true;
  };

  async textChunkVersions() {
    const chunkId = this.element.querySelector('tbody.selected').id.match(/\d+$/)[0]
    const request = new FetchRequest('get', `${this.urlValue}/text_chunks/${chunkId}/versions`, {
      responseKind: "turbo-stream"
    });
    await request.perform();
  }

  async matchingTerms(documentId, chunkId) {
    const requestTurbo = new FetchRequest('get', `/documents/${documentId}/text_chunks/${chunkId}/glossaries`, { responseKind: "turbo-stream" });
    const requestJson = new FetchRequest('get', `/documents/${documentId}/text_chunks/${chunkId}/glossaries`, { responseKind: "json" });
    const responseTurbo = await requestTurbo.perform();
    const responseJson = await requestJson.perform();
    if (responseTurbo.ok && responseJson.ok) {
      const json = await responseJson.json
      this.highlightMatchingTerms(chunkId, json['terms'])
    }
  }

  highlightMatchingTerms = (chunkId, terms) => {
    const chunkRow = document.getElementById(`chunk_${chunkId}`);
    const originalChunk = chunkRow.querySelector('.original-chunk');
    if (typeof terms == 'object' && terms.length > 0) {
      const originalTermsHightlight = document.createElement('div');
      originalTermsHightlight.classList.add('chunk-highlight');
      originalTermsHightlight.classList.add('terms');
      let originalChunkText =  originalChunk.childNodes[0].nodeValue.trim();
      terms.forEach(term => {
        originalChunkText = originalChunkText.replace(this.regexExpGenerator(term, 'i'), '<span>$&</span>')
      })
      originalTermsHightlight.innerHTML = originalChunkText;
      if (originalChunk.querySelector('.chunk-highlight.terms')) {
        originalChunk.replaceChild(originalTermsHightlight, originalChunk.querySelector('.chunk-highlight.terms'));
      } else {
        originalChunk.appendChild(originalTermsHightlight);
      }
    }
  }

  handleKeydown = (e) => {
    const target = e.currentTarget;
    if (e.key == 'Enter') {
      e.preventDefault();
      const inputsArr = Array.from(this.element.querySelectorAll('.text_chunk_translated_content'));
      if (inputsArr.indexOf(target) !== (inputsArr.length - 1)) {
        inputsArr[inputsArr.indexOf(target) + 1].focus();
      }
    }
  }

  handleInput = (e) => {
    let formTarget;
    if (e.currentTarget.tagName == 'TRIX-EDITOR') {
      const inputTarget = e.currentTarget.parentElement.querySelector('input');
      formTarget = inputTarget.form;
      inputTarget.setAttribute('value', e.currentTarget.value);
    } else if (e.currentTarget.tagName == 'FORM') {
      formTarget = e.currentTarget;
      if (this.searchFormTarget === e.currentTarget) { this.updateCleanBtn() }
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

  updateCleanBtn = () => {
    const inputCheck = [];
    this.searchFormTarget.querySelectorAll('input[type="text"]').forEach(input => {
      input.value === '' ? inputCheck.push(false) : inputCheck.push(true)
    })
    inputCheck.includes(true) ? this.cleanBtnTarget.removeAttribute('disabled') : this.cleanBtnTarget.setAttribute('disabled', '')
  }

  cleanFilters = () => {
    const formTarget = document.getElementById('search_original').form;
    document.getElementById('search_original').value = "";
    document.getElementById('search_translated').value = "";
    Rails.fire(formTarget, 'submit')
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
    for ( var i = 0; i < characters.length; i++ ) {
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

  confirmSelected = () => {
    const selectedRows = document.querySelectorAll('#tableChunks tbody.selected');
    const chunksId = Array.from(selectedRows).map(row => row.id.match(/\d+$/)[0]);

    chunksId.forEach(chunkId => {
      this.confirmChunk(chunkId);
    })
  }

  confirmAll = () => {
    const unconfirmedChunksId = Array.from(document.querySelectorAll('.text_chunk_status.unconfirmed')).map(el => el.closest('tbody').id.match(/\d+$/)[0]);

    unconfirmedChunksId.forEach(chunkId => {
      this.confirmChunk(chunkId);
    })
  }

  confirmChunk = (chunkId) => {
    Rails.ajax({
      url: `/text_chunks/${chunkId}/confirm`,
      type: "PATCH",
      success: function(data) {
        let dataComponent = document.createElement('div');
        dataComponent.innerHTML = data;
        dataComponent = dataComponent.firstChild.querySelector('template').content.querySelector('*');
        document.getElementById(dataComponent.id).parentElement.replaceChild(dataComponent, document.getElementById(dataComponent.id))
      }
    });
  }

  nextUnconfirmed = (e) => {
    e.preventDefault();
    const unconfirmedChunks = Array.from(document.querySelectorAll('.text_chunk_status.unconfirmed')).map(el => el.closest('tbody'));

    let chunkIndex = 0;
    if (unconfirmedChunks.includes(document.activeElement.closest('tbody'))) {
      chunkIndex = unconfirmedChunks.indexOf(document.activeElement.closest('tbody')) + 1;
    }
    if (chunkIndex == unconfirmedChunks.length) return;
    unconfirmedChunks[chunkIndex].querySelector('trix-editor').focus();
  }

  goRowNumber = (e) => {
    e.preventDefault();
    if (!e.currentTarget.querySelector('input.is-invalid')) {
      const rowNum = e.currentTarget.querySelector('#row_number_order').value;
      Swal.close();
      const tbodyTarget = Array.from(document.querySelectorAll('.order-num')).find(el => el.innerText == rowNum).closest('tbody');
      tbodyTarget.scrollIntoView();
      tbodyTarget.querySelector('trix-editor').focus();
    }
  }

  orderValidation = (e) => {
    const target = e.currentTarget;
    const maxOrderNum = Math.max(...Array.from(document.querySelectorAll('.order-num')).map(el => parseInt(el.innerText)));
    if (parseInt(target.value) == NaN) {
      this.setInputInvalid(target, I18n.t('javascript.modal.editor.error_invalid_value'));
    } else if (parseInt(target.value) < 1) {
      this.setInputInvalid(target, I18n.t('javascript.modal.editor.error_negative'));
    } else if (target.value > maxOrderNum) {
      this.setInputInvalid(target, I18n.t('javascript.modal.editor.error_maximum', { max_value: maxOrderNum }))
    } else {
      target.classList.remove('is-invalid');
      if (target.parentElement.querySelector('.invalid-feedback')) {
        target.parentElement.querySelector('.invalid-feedback').remove();
      }
    }
  }

  setInputInvalid = (input, message) => {
    input.classList.add('is-invalid');
    if (input.parentElement.querySelector('.invalid-feedback')) {
      input.parentElement.querySelector('.invalid-feedback').innerText = message;
    } else {
      const invalidFeedback = document.createElement('div');
      invalidFeedback.classList.add('invalid-feedback');
      invalidFeedback.innerText = message;
      input.parentElement.appendChild(invalidFeedback);
    }
  }

  submitNewTerm = ({ detail: { success } }) => {
    if (success) {
      Swal.close();
      if (document.querySelectorAll('#tableChunks tbody.selected').length == 1) {
        document.querySelector('#tableChunks tbody.selected').click();
      }
    }
  }

  // Changes the editor view in the show page
  async simpleEditor() {
    const currentTarget = event.currentTarget
    const request = new FetchRequest('get', window.location.href, {
      responseKind: "turbo-stream"
    });
    const response = await request.perform();
    if (!response.redirected) {
      this.linkChange(currentTarget);
    }
    else {
      this.addDeniedAnimation(currentTarget);
    }
  }

  async advancedEditor() {
    const currentTarget = event.currentTarget
    const request = new FetchRequest('get', `${window.location.href}/editor`, {
      responseKind: "turbo-stream"
    });
    const response = await request.perform();
    if (!response.redirected) {
      this.linkChange(currentTarget);
    }
    else {
      this.addDeniedAnimation(currentTarget);
    }
  }

  linkChange(currentTarget) {
    this.toggleLinksTarget.querySelector('.d-none').classList.remove('d-none');
    currentTarget.classList.add('d-none');
  }

  addDeniedAnimation(currentTarget) {
    currentTarget.classList.add('animation-denied');
    setTimeout(() => {
      currentTarget.classList.remove('animation-denied');
    }, 500);
  }
}
