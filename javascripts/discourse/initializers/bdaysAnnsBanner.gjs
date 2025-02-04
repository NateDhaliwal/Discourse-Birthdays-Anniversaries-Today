import Component from "@glimmer/component";
import { apiInitializer } from "discourse/lib/api";
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { inject as service } from "@ember/service";
import { defaultHomepage } from "discourse/lib/utilities";


export default apiInitializer("1.14.0", (api) => {
  //const banner_location = settings.banner_location
  api.renderInOutlet(
    settings.banner_location,
    class BdaysAnnsBanner extends Component {
      @tracked annsDataFinal = null;
      @tracked bdaysDataFinal = null;
      @tracked areBothBannersVisible = true;
      @tracked isAnnsVisible = null;
      @tracked isBdaysVisible = null;

      @service router;

      constructor() {
        super(...arguments);
        this.fetchAnnsData(); // Automatically fetch on initialization
        this.fetchBdaysData();
      }
  
      // Asynchronously fetch the data and update tracked property
      @action
      async fetchAnnsData() {
        const response = await fetch("/cakeday/anniversaries/today.json");

        let numberOfAnns = parseInt(response['total_rows_anniversaries']);
        let allAnns = response['anniversaries']; // Is a list of dicts
        console.log(allAnns);
        let allAnnsUsernames = [];

        for (let annUserdata of allAnns) {
            allAnnsUsernames.push(annUserdata['username']);
        }

        this.annsDataFinal = {'num_anns': numberOfAnns, 'anns_users': allAnnsUsernames, 'isFilled': true};
      }

      // Asynchronously fetch the data and update tracked property
      @action
      async fetchBdaysData() {
        // Declare bdaysDataFinal here
        let bdaysDataFinal;
    
        // Fetch birthdays data
        const response = await fetch("/cakeday/birthdays/today.json");
    
        // Run the logic to process the data
        let numberOfBdays = parseInt(response['total_rows_birthdays']);
        let allBdays = response['birthdays']; // Is a list of dicts
        let allBdaysUsernames = [];
    
        for (let bdayUserdata of allBdays) {
            allBdaysUsernames.push(bdayUserdata['username']);
        }
    
        this.bdaysDataFinal = {'num_bdays': numberOfBdays, 'bdays_users': allBdaysUsernames, 'isFilled': true};
      }


      @action
      updateBothBannersVisibility() {
        // Uses an inequality. If not the same (true), banner is shown. If it is the same, inequality is not satisfied, and the banner will be hidden.
        this.areBothBannersVisible = !(this.isAnnsVisible === false && this.isBdaysVisible === false); // Or: this.areBothBannersVisible = this.isAnnsVisible || this.isBdaysVisible;
      }

      
      // Getter for the data
      get annsData() {
        //return this.annsDataFinal;
        if (this.annsDataFinal !== null) {
          if (this.annsDataFinal.num_anns == 0) {
            if (settings.hide_unused_data) {
                this.annsDataFinal.isFilled = false;
                this.isAnnsVisible = false;
            } else {
                this.annsDataFinal.isFilled = false;
                this.isAnnsVisible
            }
          } else {
            this.annsDataFinal.isFilled = true;
            this.isAnnsVisible = true;
          }
          
          //this.updateBothBannersVisibility(this.annsDataFinal);
          // If the data is not loaded yet, return null or any default value
          return this.annsDataFinal;
        }
      }
  
      // Getter for the data
      get bdaysData() {
        //return this.bdaysDataFinal;
        if (this.bdaysDataFinal !== null) {
          if (this.bdaysDataFinal.num_bdays == 0) {
            if (settings.hide_unused_data) {
                this.bdaysDataFinal.isFilled = false;
                this.isBdaysVisible = false;
            } else {
                this.bdaysDataFinal.isFilled = false;
                this.isBdaysVisible = true;
            }

          } else {
            this.bdaysDataFinal.isFilled = true;
            this.isBdaysVisible = true;
          }

          //this.updateBothBannersVisibility(this.bdaysDataFinal);
          // If the data is not loaded yet, return null or any default value
          return this.bdaysDataFinal;
        }
      }

      get isHomepage() {
        const { currentRouteName } = this.router;
        return currentRouteName === `discovery.${defaultHomepage()}`;
      }

      <template>
        {{#if this.areBothBannersVisible}}
          {{#if this.isHomepage}}
            <div class='bdaysannsbanner' id='bdaysannsbanner'>
              {{#if this.isAnnsFilled}}
                <div class='anns'>
                  {{#if this.annsData.isFilled}}
                    <p>{{this.annsData.num_anns}} users are celebrating their anniversary!</p>
                    <!-- Display the anniversaries data -->
                    {{#each this.annsData.anns_users as |username|}}
                      <span><a class='mention'>{{username}}</a></span>
                    {{/each}}
                  {{else}}
                    <p>No one has their anniversary today!</p>
                  {{/if}}
                </div>
              {{/if}}
            <br />
            {{#if this.isBdaysVisible}}
              <div class='bdays'>
                {{#if this.bdaysData.isFilled}}
                  <p>{{this.bdaysData.num_bdays}} users are celebrating their birthday!</p>
                  <!-- Display the birthday data -->
                  {{#each this.bdaysData.bdays_users as |username|}}
                    <span><a class='mention'>{{username}}</a></span>
                  {{/each}}
                {{else}}
                  <p>No one is celebrating their birthday today!</p>
                {{/if}}
              </div>
            {{/if}}
          </div>
        {{/if}}
      {{/if}}
    </template>
    }
  );
});
