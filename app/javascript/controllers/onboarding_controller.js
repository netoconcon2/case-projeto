import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ['tutorialOverlay', 'tutorialStepIndicators']

  // ---------- Functions used by nextStep and previousStep functions ----------

  hideCurrentTutorial = (currentNumber) => {
    // Hide the current step and remove the highlight class
    document.getElementById(`dashboard-tutorial${currentNumber}`).classList.add('d-none');
    document.querySelector('.step-highlight').classList.remove('step-highlight');
  }

  showStep = (step) => {
    document.getElementById(`dashboard-tutorial${step}`).classList.remove('d-none');
  }

  highlightElement = (element) => {
    document.getElementById(element).classList.add('step-highlight');
  }

  changeIndicatorDots = (current, next) => {
    document.getElementById(`stepIndicator${current}`).classList.remove('active-step');
    document.getElementById(`stepIndicator${next}`).classList.add('active-step');
  }

  // ---------------------------------------------------------------------------

  nextStep = (event) => {
    event.preventDefault();
    const currentNumber = Number.parseInt(event.target.dataset.currentNumber, 10);
    const nextStepHighlight = document.getElementById(event.target.dataset.nextStepHighlight) ? event.target.dataset.nextStepHighlight : 'dashboard-tutorial-card';
    const managerOrOwner = event.target.dataset.managerOrOwner === 'true';

    this.hideCurrentTutorial(currentNumber);

    // Add the highlight class to the next highlight item
    this.highlightElement(nextStepHighlight);

    if (!managerOrOwner && currentNumber === 1) {
      // If the user doesn't have access to the plans and packages, they will skip steps 2 and 3
      this.changeIndicatorDots(currentNumber, 4)
      this.showStep(4);
    }
    else {
      this.changeIndicatorDots(currentNumber, (currentNumber + 1))
      this.showStep((currentNumber + 1));
    }
  }

  previousStep = (event) => {
    event.preventDefault();
    const currentNumber = Number.parseInt(event.target.dataset.currentNumber, 10);
    const previousStepHighlight = document.getElementById(event.target.dataset.previousStepHighlight) ? event.target.dataset.previousStepHighlight : 'dashboard-tutorial-card';
    const managerOrOwner = event.target.dataset.managerOrOwner === 'true';

    this.hideCurrentTutorial(currentNumber);

    // Add the highlight class to the next highlight item
    this.highlightElement(previousStepHighlight);

    if (!managerOrOwner && currentNumber === 4) {
      // If the user doesn't have access to the plans and packages, they will skip steps 2 and 3
      this.changeIndicatorDots(currentNumber, 1)
      this.showStep(1);
    }
    else {
      this.changeIndicatorDots(currentNumber, (currentNumber - 1))
      this.showStep((currentNumber - 1));
    }
  }

  hideTutorial = (event) => {
    event.preventDefault();
    // Remove the highlight class
    const currentHighlight = event.target.dataset.currentHighlight;
    document.querySelector('.step-highlight').classList.remove('step-highlight');

    // Hide the tutorial layer
    this.tutorialOverlayTarget.classList.add('d-none');
  }
}
