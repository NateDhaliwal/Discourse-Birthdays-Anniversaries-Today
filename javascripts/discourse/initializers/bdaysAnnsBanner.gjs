import Component from "@glimmer/component";
import { apiInitializer } from "discourse/lib/api";
import { ajax } from "discourse/lib/ajax";
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { inject as service } from "@ember/service";
import { defaultHomepage } from "discourse/lib/utilities";
import { getOwner } from '@ember/application';


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
            fetchAnnsData() {
                const response = fetch("/cakeday/anniversaries/today.json");
                const json = response.json();
        
                let numberOfAnns = parseInt(json['total_rows_anniversaries']);
                let allAnns = json['anniversaries']; // Is a list of dicts
                let allAnnsUsernames = [];
        
                for (let annUserdata of allAnns) {
                    allAnnsUsernames.push(annUserdata['username']);
                }
        
                this.annsDataFinal = {'num_anns': numberOfAnns, 'anns_users': allAnnsUsernames, 'visible': true, 'isFilled': true};
                this.updateBothBannersVisibility(this.annsDataFinal);
            }

            // Asynchronously fetch the data and update tracked property
            @action
            fetchBdaysData() {
                 // Declare bdaysDataFinal here
                let bdaysDataFinal;
            
                // Fetch birthdays data
                const response = fetch("/cakeday/birthdays/today.json");
                const json = response.json();
            
                // Run the logic to process the data
                let numberOfBdays = parseInt(json['total_rows_birthdays']);
                let allBdays = json['birthdays']; // Is a list of dicts
                let allBdaysUsernames = [];
            
                for (let bdayUserdata of allBdays) {
                    allBdaysUsernames.push(bdayUserdata['username']);
                }
            
                this.bdaysDataFinal = {'num_bdays': numberOfBdays, 'bdays_users': allBdaysUsernames, 'visible': true, 'isFilled': true};
                this.updateBothBannersVisibility(this.bdaysDataFinal);
                //console.log(annsDataFinal);  // Just to verify the result
            }


            @action
            updateBothBannersVisibility(bannerData) {
                console.log(bannerData.num_anns);
                // Check if it's anns or bdays
                if (bannerData.num_anns) { // It's anns
                    console.log('Anns:')
                    console.log(bannerData.num_anns);
                    if (bannerData.num_anns == 0 && settings.hide_unused_data) {
                        console.log(`Anns+setting: ${bannerData.num_anns == 0 && settings.hide_unused_data}`);
                        this.isAnnsVisible = false;
                        console.log(`isAnnsV: ${this.isAnnsVisible}`);
                        //console.log(this.isBdaysVisible);
                    }
                } else { // It's bdays  
                    console.log(bannerData.num_bdays);
                    if (bannerData.num_bdays == 0 && settings.hide_unused_data) {
                        console.log(`Bdays+setting: ${bannerData.num_bdays == 0 && settings.hide_unused_data}`);
                        this.isBdaysVisible = false;
                        console.log(`isBdaysV: ${this.isBdaysVisible}`);
                        //console.log(this.isAnnsVisible);
                    }
                }
                console.log(`isAnnsV: ${this.isAnnsVisible}`);
                console.log(`isBdaysV: ${this.isBdaysVisible}`);
                // Uses an inequality. If not the same (true), banner is shown. If it is the same, inequality is not satisfied, and the banner will be hidden.
                this.areBothBannersVisible = !(this.isAnnsVisible === false && this.isBdaysVisible === false); // Or: this.areBothBannersVisible = this.isAnnsVisible || this.isBdaysVisible;
                console.log(this.areBothBannersVisible);
            }

            
            // Getter for the data
            get annsData() {
                //return this.annsDataFinal;
                if (this.annsDataFinal.num_anns == 0) {
                    if (settings.hide_unused_data) {
                        this.annsDataFinal.isFilled = false;
                        this.annsDataFinal.visible = false;
                        this.isAnnsVisible = false;
                    } else {
                        this.annsDataFinal.isFilled = false;
                    }
                } else {
                    this.annsDataFinal.isFilled = true;
                    this.annsDataFinal.visible = true;
                }
                
                //this.updateBothBannersVisibility(this.annsDataFinal);
                // If the data is not loaded yet, return null or any default value
                return this.annsDataFinal;
            
            }
            
            // Getter for the data
            get bdaysData() {
                //return this.bdaysDataFinal;
                if (this.bdaysDataFinal !== null) {
                    if (this.bdaysDataFinal.num_bdays == 0) {
                        if (settings.hide_unused_data) {
                            this.bdaysDataFinal.isFilled = false;
                            this.bdaysDataFinal.visible = false;
                            this.isBdaysVisible = false;
                            console.log(`this.isAnnsVisible: ${this.isAnnsVisible}`);
                            console.log(`this.isBdaysVisible: ${this.isBdayVisible}`);
                        } else {
                            this.bdaysDataFinal.isFilled = false;
                            this.bdaysDataFinal.visible = true;
                        }
    
                    } else {
                        this.bdaysDataFinal.isFilled = true;
                        this.bdaysDataFinal.visible = true;
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
            //console.log(this.areBothBannersVisible);
            
            <template>
                {{#if this.areBothBannersVisible}}
                    {{#if this.isHomepage}}
                        <div class='bdaysannsbanner' id='bdaysannsbanner'>
                            {{#if this.annsData.visible}}
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
                            {{#if this.bdaysData.visible}}
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
