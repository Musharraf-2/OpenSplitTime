import {Controller} from "stimulus"

export default class extends Controller {

    static targets = ["mapInfo"]

    connect() {
        const courseId = this.mapInfoTarget.dataset.courseId;
        const splitId = this.mapInfoTarget.dataset.splitId;

        Rails.ajax({
            url: "/courses/" + courseId + '.json',
            type: "GET",
            success: function (data) {
                const attributes = data.data.attributes;

                var locations = null;
                if(splitId === undefined) {
                    locations = attributes.locations;
                } else {
                    locations = attributes.locations.filter(function(e) {
                        return e.id === parseInt(splitId)
                    })
                }

                const trackPoints = attributes.trackPoints;
                gmap_show(locations, trackPoints);
            }
        })
    }
}
