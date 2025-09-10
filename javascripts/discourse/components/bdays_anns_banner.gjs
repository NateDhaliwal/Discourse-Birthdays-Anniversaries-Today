import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { defaultHomepage } from "discourse/lib/utilities";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import { and, gt } from "truth-helpers";
import { on } from "@ember/modifier";
import { ajax } from "discourse/lib/ajax";

export default class BirthdaysAnniversariesBanner extends Component {
  // Init data
  @tracked num_anns;
  @tracked anns_list;
  @tracked num_bdays;
  @tracked bdays_list;
  @tracked loading = true;

  @service router;

  constructor() {
    super(...arguments);
    this.fetchAnnsData();
    this.fetchBdaysData();
  }

  async fetchAnnsData() {
    console.log("Anns fetched!");
    const annsData = await ajax("/cakeday/anniversaries/today");
    const numAnns = annsData.total_rows_anniversaries;
    const usersAnns = [];
    annsData.anniversaries.forEach((anns) => {
      usersAnns.push(settings.show_username? anns.username : anns.name);
    });
    this.num_anns = numAnns;
    this.anns_list = usersAnns;
    console.log(numAnns);
    console.log(usersAnns);
    console.log(this.num_anns);
    console.log(this.anns_list);
  }

  async fetchBdaysData() {
    console.log("Bdays fetched!");
    const bdaysData = await ajax("/cakeday/birthdays/today");
    const numBdays = bdaysData.total_rows_birthdays;
    const usersBdays = [];
    bdaysData.birthdays.forEach((anns) => {
      usersAnns.push(settings.show_username? anns.username : anns.name);
    });
    this.num_bdays = numBdays;
    this.bdays_list = usersBdays;
    console.log(numBdays);
    console.log(usersBdays);
    console.log(this.num_bdays);
    console.log(this.bdays_list);
    this.loading = false;
  }

  get isHomepage() {
    const { currentRouteName } = this.router;
    return currentRouteName === `discovery.${defaultHomepage()}`;
  }

  get showBanner() {
    this.fetchAnnsData();
    this.fetchBdaysData();
    return this.num_bdays > 0 || this.num_anns > 0;
  }  

  <template>
    <div>
      {{this.showBanner}}
      {{this.num_anns}}
      {{this.num_bdays}}
      {{this.isHomepage}}
      <ConditionalLoadingSpinner @condition={{this.loading}} />
      {{#if (and this.showBanner this.isHomepage) }}
        <div class='bdaysannsbanner' id='birthdays_anniversaries_banner'>
          {{#if (gt this.num_anns 0) }}
            <div class='anns'>
              <p>{{this.num_anns}} users are celebrating their anniversary today!</p>
              {{#each this.anns_list as |username_name|}}
                <span><a class='mention'>{{username_name}}</a></span>
              {{/each}}
            </div>
          {{/if}}
          <br />
          {{#if (gt this.num_bdays 0) }}
            <div class='bdays'>
              <p>{{this.num_bdays}} users are celebrating their birthday today!</p>
              {{#each this.bdays_list as |username_name|}}
                <span><a class='mention'>{{username_name}}</a></span>
              {{/each}}
            </div>
          {{/if}}
        </div>
      {{/if}}
    </div>
  </template>
}
