import EditorController from "./editor_controller";

export default class extends EditorController {
  connect = () => {
    if (this.element.querySelector('.text_chunk_input')) {
      this.chunkInitialize();
      this.highlight();
    }
  }

  highlight = () => {
    const sensitiveCase = document.getElementById('search_sensitive_case').checked;
    const option = sensitiveCase ? '' : 'i'
    
    const originalTextInput = document.getElementById('search_original');
    const originalChunk = this.element.querySelector('.original-chunk');
    if (originalTextInput.value !== "" && this.regexExpGenerator(originalTextInput.value, option).test(originalChunk.innerText)) {
      const originalHightlight = document.createElement('div');
      originalHightlight.classList.add('chunk-highlight');
      originalHightlight.classList.add('search-results');
      originalHightlight.innerHTML = originalChunk.innerText;
      if (originalChunk.querySelector('.chunk-highlight')) {
        originalChunk.querySelectorAll('.chunk-highlight').forEach(highlightDiv => {
          originalHightlight.innerHTML = originalHightlight.innerHTML.slice(highlightDiv.innerText.length);
        })
      }
      originalHightlight.innerHTML = originalHightlight.innerHTML.replace(this.regexExpGenerator(originalTextInput.value, option), '<span>$&</span>');
      originalChunk.appendChild(originalHightlight);
    }
    
    const translatedTextInput = document.getElementById('search_translated');
    const translatedChunk = this.element.querySelector('.translated-chunk');
    if (translatedTextInput.value !== "" && this.regexExpGenerator(translatedTextInput.value, option).test(translatedChunk.innerText)) {
      const trixEditorClone = this.element.querySelector('trix-editor').cloneNode(true);
      trixEditorClone.removeAttribute('data-action');
      this.element.querySelector('.text_chunk_rich_translated').appendChild(trixEditorClone);
      const matches = [...trixEditorClone.editor.getDocument().toString().matchAll(this.regexExpGenerator(translatedTextInput.value, option))];
      matches.forEach(result => {
        trixEditorClone.editor.setSelectedRange([result['index'], (result['index'] + result[0].length)]);
        trixEditorClone.editor.activateAttribute('highlight');
      })
      let highlightEl = document.createElement('div');
      highlightEl.classList.add('chunk-highlight');
      highlightEl.innerHTML = trixEditorClone.value;
      trixEditorClone.parentElement.replaceChild(highlightEl, trixEditorClone);
    }
  }

  chunkInitialize = () => {
    this.element.setAttribute('data-action', 'click->editor#selectRows focusin->editor#selectFocusedRow');
    
    const chunkInput = this.element.querySelector('.text_chunk_input');
    const trixEditor = document.createElement('trix-editor');
    trixEditor.classList.add('trix-content');
    trixEditor.classList.add('text_chunk_translated_content');
    trixEditor.setAttribute('input', chunkInput.id);
    trixEditor.setAttribute('toolbar', 'chunk-trix-toolbar');
    trixEditor.innerHTML = chunkInput.value;
    trixEditor.setAttribute('data-action', 'trix-change->editor#handleInput keydown->editor#handleKeydown');

    if (!this.element.querySelector('trix-editor')) {
      this.element.querySelector('.text_chunk_rich_translated').appendChild(trixEditor);
    }
  }
}