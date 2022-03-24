import AriaController from "./aria_controller";

export default class extends AriaController {
  static targets = ["dashNav", "btnToggle" ]

  connect = () => {
    this.mobileChange();
    window.addEventListener('resize', this.mobileChange);
    this.activateItem();
    const width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
    if (width >= 992) {this.minimizeMenu()} /* Navbar starts open in large and extra large screens */
  }

  activateItem = () => {
    const currentPath = document.location.pathname;
    document.querySelectorAll('.dash-nav-options .dash-nav-item').forEach((item) => {
      if ((currentPath.includes(item.pathname) && (item.pathname !== "/" && item.pathname !== "/en")) || currentPath === item.pathname) {
        item.classList.add('active');
        this.ariaCurrent(item);
      }
      else {
        item.classList.remove('active');
      }
    })
  }

  mobileChange = () => {
    const menu = document.getElementById('nav-menu')
    const navIcon = document.getElementById('bars')
    const iconClone = navIcon.cloneNode(true);
    iconClone.setAttribute('id', 'menu-icon');
    iconClone.querySelector('#hamburger-3').setAttribute('id', 'ham-3-menu')
    const menuIcon = document.getElementById('menu-icon');
    const width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
    if (width / parseFloat(
      getComputedStyle(
        document.querySelector('html')
      )['font-size']
    ) <= 48 && !menuIcon) {
      menu.insertAdjacentElement('afterbegin', iconClone);
    }
    if (width / parseFloat(
      getComputedStyle(
        document.querySelector('html')
      )['font-size']
    ) > 48 && menuIcon) {
      menuIcon.remove();
    }
    this.ariaNav(this.dashNavTarget, this.btnToggleTargets);
  }

  minimizeMenu = () => {
    this.dashNavTarget.classList.toggle('minimized');
    if (this.dashNavTarget.classList.contains('minimized')) {
      this.addTooltipMenu(this.dashNavTarget.querySelectorAll('.dash-nav-item'))
    } else {
      this.removeTooltipMenu(this.dashNavTarget.querySelectorAll('.dash-nav-item'))
    }
    this.ariaNav(this.dashNavTarget, this.btnToggleTargets);
  }

  addTooltipMenu = (navLinks) => {
    navLinks.forEach((link) => {
      const text = link.querySelector('p').innerText;
      link.setAttribute('data-tippy-content', text);
    })
  }

  removeTooltipMenu = (navLinks) => {
    navLinks.forEach((link) => {
      link.removeAttribute('data-tippy-content');
    })
  }

  disconnect = () => {
    window.removeEventListener('resize', this.mobileChange);
  }
}
