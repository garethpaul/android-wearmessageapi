package garethpaul.com.wearer;

import java.util.HashMap;
import java.util.Map;

final class MessageDeliveryGate {
    private final WearMessage.RecentMessageIds recentMessageIds;
    private final MessageDeliveryRateLimiter deliveryRateLimiter;
    private final Map<String, Reservation> pendingReservations =
            new HashMap<String, Reservation>();

    MessageDeliveryGate(int maxRecentMessageIds, int maxRateLimitedLanes,
            long minDeliveryIntervalMillis) {
        recentMessageIds = new WearMessage.RecentMessageIds(maxRecentMessageIds);
        deliveryRateLimiter = new MessageDeliveryRateLimiter(
                maxRateLimitedLanes, minDeliveryIntervalMillis);
    }

    synchronized Reservation reserve(String sourceNodeId, String messagePath, int requestId,
            long acceptedAtMillis) {
        String normalizedSourceNodeId = WearMessage.normalizeText(sourceNodeId);
        String canonicalPath = canonicalPath(messagePath);
        if (canonicalPath.length() == 0) {
            return null;
        }

        String identity = identity(normalizedSourceNodeId, requestId);
        if (pendingReservations.containsKey(identity)) {
            return null;
        }

        if (!recentMessageIds.record(sourceNodeId, requestId)) {
            return null;
        }

        if (!deliveryRateLimiter.allow(
                cooldownIdentity(normalizedSourceNodeId, canonicalPath), acceptedAtMillis)) {
            recentMessageIds.forget(sourceNodeId, requestId);
            return null;
        }

        Reservation reservation = new Reservation(
                normalizedSourceNodeId, canonicalPath, requestId, acceptedAtMillis);
        pendingReservations.put(identity, reservation);
        return reservation;
    }

    synchronized boolean commit(Reservation reservation) {
        return removePendingReservation(reservation);
    }

    synchronized boolean release(Reservation reservation) {
        if (!removePendingReservation(reservation)) {
            return false;
        }

        boolean releasedRateLimit = deliveryRateLimiter.forget(
                cooldownIdentity(reservation.sourceNodeId, reservation.canonicalPath),
                reservation.acceptedAtMillis);
        boolean releasedReplay = recentMessageIds.forget(
                reservation.sourceNodeId, reservation.requestId);
        return releasedRateLimit && releasedReplay;
    }

    private boolean removePendingReservation(Reservation reservation) {
        if (reservation == null) {
            return false;
        }

        String identity = identity(reservation.sourceNodeId, reservation.requestId);
        if (pendingReservations.get(identity) != reservation) {
            return false;
        }
        pendingReservations.remove(identity);
        return true;
    }

    private static String identity(String sourceNodeId, int requestId) {
        return sourceNodeId + "\n" + requestId;
    }

    private static String cooldownIdentity(String sourceNodeId, String canonicalPath) {
        return sourceNodeId + "\n" + canonicalPath;
    }

    private static String canonicalPath(String messagePath) {
        if (WearMessage.isStartActivityPath(messagePath)) {
            return WearMessage.START_ACTIVITY;
        }
        if (WearMessage.isWearMessagePath(messagePath)) {
            return WearMessage.WEAR_MESSAGE_PATH;
        }
        return "";
    }

    static final class Reservation {
        private final String sourceNodeId;
        private final String canonicalPath;
        private final int requestId;
        private final long acceptedAtMillis;

        private Reservation(String sourceNodeId, String canonicalPath, int requestId,
                long acceptedAtMillis) {
            this.sourceNodeId = sourceNodeId;
            this.canonicalPath = canonicalPath;
            this.requestId = requestId;
            this.acceptedAtMillis = acceptedAtMillis;
        }
    }
}
