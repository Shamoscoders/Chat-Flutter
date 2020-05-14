enum NotifTrigger { forground, background }

class Notif {
  NotifTrigger trigger;
  Map<String, dynamic> message;

  Notif(this.trigger, this.message);
}
