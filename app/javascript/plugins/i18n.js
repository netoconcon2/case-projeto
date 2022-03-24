import I18n from "i18n-js"
I18n.locale = document.getElementById('page-container').dataset.locale;
I18n.translations = JSON.parse(gon.translations);
export default I18n
