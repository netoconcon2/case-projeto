import { Controller } from "stimulus";
import I18n from "../plugins/i18n";
import Chart from 'chart.js';

export default class extends Controller {
  static targets = ["documentsChart", "usersChart"]

  connect() {
    if (this.hasDocumentsChartTarget) {
      const BarChart = new Chart(this.documentsChartTarget, {
        type: 'bar',
        data: {
          labels: [I18n.t('activerecord.attributes.document.status_list.original'), I18n.t('activerecord.attributes.document.status_list.being_translated'), I18n.t('activerecord.attributes.document.status_list.being_reviewed'), I18n.t('activerecord.attributes.document.status_list.translated')],
          datasets: [{
            data: JSON.parse(this.documentsChartTarget.dataset.count),
            backgroundColor: [
              '#C82119',
              '#D95917',
              '#FFD131',
              '#00CC25',
            ],
            borderColor: [
              '#C82119',
              '#D95917',
              '#FFD131',
              '#00CC25',
            ],
            borderWidth: 1
          }]
        },
        options: {
          scales: {
            yAxes: [{
              ticks: {
                beginAtZero: true
              }
            }]
          },
          legend: {
              display: false
           }
        }
      });
    }

    if (this.hasUsersChartTarget) {
      const PieChart = new Chart(this.usersChartTarget, {
        type: 'doughnut',
        data: {
          labels: JSON.parse(this.usersChartTarget.dataset.usersNames),
          datasets: [{
            data: JSON.parse(this.usersChartTarget.dataset.count),
            backgroundColor: this.getRandomColors(this.usersChartTarget.dataset.count.length),
            borderWidth: 1
          }]
        },
        options: {
          legend: {
              display: false
           }
        }
      });
    }
  }

  getRandomColors(n_colors) {
    const letters = '0123456789ABCDEF';
    const colors = [];
    for(let i = 0; i < n_colors; i++){
      let color = '#';
      for (let j = 0; i < 6; i++) {
        color += letters[Math.floor(Math.random() * 16)];
      }
      colors.push(color);
    }

    return colors;
  }

}
