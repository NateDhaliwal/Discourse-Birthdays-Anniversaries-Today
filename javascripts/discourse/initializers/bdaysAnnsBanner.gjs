import Component from "@glimmer/component";
import { apiInitializer } from "discourse/lib/api";
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { inject as service } from "@ember/service";
import { defaultHomepage } from "discourse/lib/utilities";


/*
const xhr = new XMLHttpRequest();
xhr.open("GET", "/cakeday/anniversaries/today.json");
xhr.send();
xhr.responseType = "json";
xhr.onload = () => {
    if (xhr.readyState == 4 && xhr.status == 200) {
        let resp = xhr.response;
        let numberOfAnns = resp['total_rows_anniversaires'];
        let allAnns = resp['anniversaries']; // Is a list of dicts
        console.log(allAnns);
        let allAnnsUsernames = [];
        for (var annUserdata in allAnns) {
            console.log(allAnns[annUserdata]['username']);
            allAnnsUsernames.push(allAnns[annUserdata]['username']);
        }
        var annsOfData = {'num_anns': numberOfAnns, 'anns_users': allAnnsUsernames};
        
    }
};
return annsOfData;
*/

var bothBannersVisible = false;

export default apiInitializer("1.14.0", (api) => {
    //const banner_location = settings.banner_location
    api.renderInOutlet(
        settings.banner_location,
        class BdaysAnnsBanner extends Component {
            @tracked annsDataFinal = null;
            @tracked bdaysDataFinal = null;
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
                const json = await response.json();
        
                let numberOfAnns = parseInt(json['total_rows_anniversaries']);
                let allAnns = json['anniversaries']; // Is a list of dicts
                let allAnnsUsernames = [];
        
                for (let annUserdata of allAnns) {
                    allAnnsUsernames.push(annUserdata['username']);
                }
        
                this.annsDataFinal = {'num_anns': numberOfAnns, 'anns_users': allAnnsUsernames, 'visible': true, 'isFilled': true};
            }

            // Asynchronously fetch the data and update tracked property
            @action
            async fetchBdaysData() {
                 // Declare bdaysDataFinal here
                let bdaysDataFinal;
            
                // Fetch birthdays data
                const response = await fetch("/cakeday/birthdays/today.json");
                const json = await response.json();
            
                // Run the logic to process the data
                let numberOfBdays = parseInt(json['total_rows_birthdays']);
                let allBdays = json['birthdays']; // Is a list of dicts
                let allBdaysUsernames = [];
            
                for (let bdayUserdata of allBdays) {
                    allBdaysUsernames.push(bdayUserdata['username']);
                }
            
                this.bdaysDataFinal = {'num_bdays': numberOfBdays, 'bdays_users': allBdaysUsernames, 'visible': true, 'isFilled': true};
                
                //console.log(annsDataFinal);  // Just to verify the result
            }


            // Getter for the data
            get annsData() {
                //return this.annsDataFinal;
                if (this.annsDataFinal !== null) {
                        if (this.annsDataFinal.num_anns == 0) {
                            if (settings.hide_unused_data) {
                                this.annsDataFinal.isFilled = false;
                                this.annsDataFinal.visible = false;
                                bothBannersVisible = false;
                            } else {
                                this.annsDataFinal.isFilled = false;
                                this.annsDataFinal.visible = true;
                                bothBannersVisible = true;
                            }
                        } else {
                            this.annsDataFinal.isFilled = true;
                            this.annsDataFinal.visible = true;
                            bothBannersVisible = true;
                        }
                        
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
                                this.bdaysDataFinal.visible = false;
                                if (bothBannersVisible == false) {
                                    bothBannersVisible = false;
                                } else {
                                    bothBannersVisible = true;
                                }
                            } else {
                                this.bdaysDataFinal.isFilled = false;
                                this.bdaysDataFinal.visible = true;
                                if (bothBannersVisible == false) {
                                    bothBannersVisible = false;
                                } else {
                                    bothBannersVisible = true;
                                }
                            }

                        } else {
                            this.bdaysDataFinal.isFilled = true;
                            this.bdaysDataFinal.visible = true;
                            if (bothBannersVisible == false) {
                                bothBannersVisible = false;
                            } else {
                                bothBannersVisible = true;
                            }
                        }
                        
                        // If the data is not loaded yet, return null or any default value
                        return this.bdaysDataFinal;
                }
            }

            get isHomepage() {
                const { currentRouteName } = this.router;
                return currentRouteName === `discovery.${defaultHomepage()}`;
            }

            get bothBannersVisibleGetter() {
                return bothBannersVisible;
            }

            <template>
                {{#if this.isHomepage}}
                    <p>{{this.bothBannersVisibleGetter}}</p>
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
            </template>

        }
    );
});
