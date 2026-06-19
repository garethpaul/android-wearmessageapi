package garethpaul.com.wearer;

import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

final class MessageDeliveryRateLimiter {
    private final int maxSources;
    private final long minIntervalMillis;
    private final LinkedHashMap<String, Long> acceptedDeliveries =
            new LinkedHashMap<String, Long>();

    MessageDeliveryRateLimiter(int maxSources, long minIntervalMillis) {
        if (maxSources <= 0 || minIntervalMillis <= 0L) {
            throw new IllegalArgumentException("Delivery limits must be positive");
        }
        this.maxSources = maxSources;
        this.minIntervalMillis = minIntervalMillis;
    }

    synchronized boolean allow(String sourceNodeId, long nowMillis) {
        String source = normalizeSource(sourceNodeId);
        if (source.length() == 0 || nowMillis < 0L) {
            return false;
        }

        Long previousDelivery = acceptedDeliveries.get(source);
        if (previousDelivery != null
                && (nowMillis < previousDelivery.longValue()
                        || nowMillis - previousDelivery.longValue() < minIntervalMillis)) {
            return false;
        }

        acceptedDeliveries.remove(source);
        acceptedDeliveries.put(source, Long.valueOf(nowMillis));
        while (acceptedDeliveries.size() > maxSources) {
            Iterator<Map.Entry<String, Long>> iterator =
                    acceptedDeliveries.entrySet().iterator();
            iterator.next();
            iterator.remove();
        }
        return true;
    }

    synchronized boolean forget(String sourceNodeId, long acceptedAtMillis) {
        String source = normalizeSource(sourceNodeId);
        Long acceptedDelivery = acceptedDeliveries.get(source);
        if (acceptedDelivery == null || acceptedDelivery.longValue() != acceptedAtMillis) {
            return false;
        }
        acceptedDeliveries.remove(source);
        return true;
    }

    private static String normalizeSource(String sourceNodeId) {
        return sourceNodeId == null ? "" : sourceNodeId.trim();
    }
}
