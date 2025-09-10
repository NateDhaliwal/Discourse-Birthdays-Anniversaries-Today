import { apiInitializer } from "discourse/lib/api";

import BirthdaysAnnsBanner from "../components/bdays_anns_banner.gjs";

export default apiInitializer((api) => {
  api.renderInOutlet(settings.banner_location, BirthdaysAnnsBanner);
});
