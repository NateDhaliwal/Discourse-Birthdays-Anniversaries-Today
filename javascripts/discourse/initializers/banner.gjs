import Component from "@glimmer/component";
import { apiInitializer } from "discourse/lib/api";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { defaultHomepage } from "discourse/lib/utilities";
import { gt, and } from "truth-helpers";
import ajax from "discourse/lib/ajax";

export default apiInitializer((api) => {
  api.renderInOutlet(
    settings.banner_location,
    class BdaysAnnsBanner extends Component {
      // Init data
      num_anns = 0;
      anns_list = [];
      num_bdays = 0;
      bdays_list = [];

      @service router;

      constructor() {
        super(...arguments);
        this.fetchAnnsData(); // Automatically fetch on initialization
        this.fetchBdaysData();
      }

      async fetchAnnsData() {
        const annsData = await ajax("/cakeday/anniversaries/today");
        const numAnns = annsData.total_rows_anniversaries;
        const usersAnns = [];
        annsData.anniversaries.forEach((anns) => {
          usersAnns.push(settings.show_username? anns.username : anns.name);
        })
        this.num_anns = numAnns;
        this.anns_list = usersAnns;
      }

      async fetchBdaysData() {
        const bdaysData = await ajax("/cakeday/birthdays/today");
        const numBdays = bdaysData.total_rows_birthdays;
        const usersBdays = [];
        bdaysData.birthdays.forEach((anns) => {
          usersAnns.push(settings.show_username? anns.username : anns.name);
        })
        this.num_bdays = numBdays;
        this.bdays_list = usersBdays;
      }

      get isHomepage() {
        const { currentRouteName } = this.router;
        return currentRouteName === `discovery.${defaultHomepage()}`;
      }

      get showBanner() {
        return this.num_bdays > 0 && this.num_anns > 0;
      }  

      <template>
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
      </template>
    }
  );
});
