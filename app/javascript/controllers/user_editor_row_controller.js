import EditorController from "./editor_controller";

export default class extends EditorController {
  connect = () => {
    if (this.element.querySelector('.text_chunk_input')) {
      this.chunkInitialize();
    }
  }

  chunkInitialize = () => {
    const chunkInput = this.element.querySelector('.text_chunk_input');
    const trixEditor = document.createElement('trix-editor');
    trixEditor.classList.add('trix-content');
    trixEditor.classList.add('text_chunk_translated_content');
    trixEditor.setAttribute('input', chunkInput.id);
    trixEditor.setAttribute('toolbar', 'chunk-trix-toolbar');
    trixEditor.innerHTML = chunkInput.value;
    trixEditor.setAttribute('data-action', 'trix-change->user-editor#handleInput');

    if (!this.element.querySelector('trix-editor')) {
      this.element.querySelector('.text_chunk_rich_translated').appendChild(trixEditor);
    }
  }
}
