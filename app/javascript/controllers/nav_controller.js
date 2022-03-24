import AriaController from "./aria_controller";
import smoothscroll from 'smoothscroll-polyfill';

export default class extends AriaController {
  static targets = ["navbar", "navLinks"]

  connect = () => {
    smoothscroll.polyfill();
    this.mobileChange();
    window.addEventListener('resize', this.mobileChange);
    this.clickEventForLinks();
    this.updateNavbarOnScroll();
    window.addEventListener('scroll', this.updateNavbarOnScroll);
  }

  clickEventForLinks = () => {
    this.navLinksTarget.querySelectorAll('a[href*="#"]:not([href="#"]):not([href="#0"])').forEach((link) => {
      if (
        location.pathname.replace(/^\//, '') == link.pathname.replace(/^\//, '')
        &&
        location.hostname == link.hostname
      ) {
        link.setAttribute('data-action', 'click->nav#smoothScrolling')
      }
    })
  }

  smoothScrolling = (e) => {
    e.preventDefault();
    const targetHash = e.currentTarget.hash;
    let target = document.querySelector(`${targetHash}`);
    target = target ? target : document.querySelector(`[name='${targetHash.slice(1)}']`);
    if (targetHash && target) {
      target.scrollIntoView({
        behavior: 'smooth'
      });
      if (history.pushState) {
        history.pushState(null, null, targetHash);
      }
      else {
        location.hash = targetHash;
      }
      target.focus();
      if (document.activeElement === target) {
        return false;
      } else {
        target.setAttribute('tabindex', '-1');
        target.focus({ preventScroll: true });
        target.removeAttribute('tabindex');
      }
    }
  }

  mobileChange = () => {
    const width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
    if (width / parseFloat(
      getComputedStyle(
        document.querySelector('html')
      )['font-size']
    ) <= 48) {
      this.navLinksTarget.setAttribute('data-bs-toggle', 'collapse');
    } else {
      this.navLinksTarget.removeAttribute('data-bs-toggle')
    }
  }

  updateNavbarOnScroll = () => {
    if (window.scrollY > 0 || window.location.pathname != "/") {
      this.navbarTarget.classList.add('nav-min');
      document.getElementById('content-wrap').classList.add('pt-min');
    } else {
      this.navbarTarget.classList.remove('nav-min');
      document.getElementById('content-wrap').classList.remove('pt-min');
    }
    if (window.location.pathname != "/") {
      document.querySelector('#content-wrap.home').style.transition = "none"
    }
  }

  disconnect = () => {
    window.removeEventListener('scroll', this.updateNavbarOnScroll);
    window.removeEventListener('resize', this.mobileChange);
  }
}
