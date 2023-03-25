import {Controller} from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {

    connect() {
        let notificationController = this;

        this.subscription = consumer.subscriptions.create(
            {
                channel: this.data.get("channel"),
                id: this.data.get("id")
            },
            {
                connected() {
                    notificationController.triggerRawTimesPush();
                },
                disconnected() {
                },
                received(data) {
                    if (data.event !== "raw_times_available") { return }

                    const unreviewedCount = (typeof data.detail.unreviewed === "number") ? data.detail.unreviewed : 0;
                    const unmatchedCount = (typeof data.detail.unmatched === "number") ? data.detail.unmatched : 0;
                    notificationController.displayNewCount(unreviewedCount, unmatchedCount);
                }
            }
        )
    }

    disconnect() {
        this.subscription.unsubscribe();
    }

    displayNewCount(unreviewedCount, unmatchedCount) {
        const countBadge = document.getElementById("js-pull-times-count");
        const forceCountBadge = document.getElementById("js-force-pull-times-count");
        const unreviewedClass = (unreviewedCount > 0) ? "badge bg-danger" : "badge";
        const unreviewedText = (unreviewedCount > 0) ? unreviewedCount : "";
        const unmatchedText = (unmatchedCount > 0) ? unmatchedCount : "";
        countBadge.className = unreviewedClass
        countBadge.textContent = unreviewedText
        forceCountBadge.textContent = unmatchedText

        if (unreviewedCount > 0) {
            const notifier = this.data.get("notifier");

            if (!notifier || !notifier.$ele.is(":visible") || notifier.$ele.data("closing")) {
                const newNotifier = $.notify({
                    icon: "fas fa-stopwatch",
                    title: "Raw Times Need Review",
                    message: "Click to pull times.",
                    url: "#js-pull-times",
                    target: "_self"
                }, {delay: 0});

                this.data.set("notifier", newNotifier)
            }
        } else if (notifier) {
            notifier.close();
        }
    }

    triggerRawTimesPush() {
        const url = "/api/v1/event_groups/" + this.data.get("id") + "/trigger_raw_times_push";
        Rails.ajax({
            type: "GET",
            url: url,
            dataType: "json",
        });
    }
}
