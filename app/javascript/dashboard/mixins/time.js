import {
  format,
  isSameYear,
  fromUnixTime,
  formatDistanceToNow,
  intervalToDuration,
  formatDuration,
} from 'date-fns';
import { ptBR } from 'date-fns/locale';

export default {
  methods: {
    messageStamp(time, dateFormat = 'h:mm a') {
      const unixTime = fromUnixTime(time);
      return format(unixTime, dateFormat);
    },
    messageTimestamp(time, dateFormat = 'MMM d, yyyy') {
      const messageTime = fromUnixTime(time);
      const now = new Date();
      const messageDate = format(messageTime, dateFormat);
      if (!isSameYear(messageTime, now)) {
        return format(messageTime, 'LLL d y, h:mm a');
      }
      return messageDate;
    },
    dynamicTime(time) {
      const unixTime = fromUnixTime(time);
      return formatDistanceToNow(unixTime, { addSuffix: true, locale: ptBR });
    },
    dateFormat(time, dateFormat = 'MMM d, yyyy') {
      const unixTime = fromUnixTime(time);
      return format(unixTime, dateFormat);
    },
    formatTime(timeInSeconds, locale = ptBR) {
      if (timeInSeconds) {
        const duration = intervalToDuration({
          start: 0,
          end: timeInSeconds * 1000,
        });

        const formattedTime = formatDuration(duration, { locale });

        return formattedTime;
      }
      return '-';
    },
    shortTimestamp(time) {
      const convertToShortTime = time
        .replace(/about|over|almost|/g, '')
        .replace('less than a minute ago', 'agora')
        .replace(' minute ago', 'min')
        .replace(' minutes ago', 'min')
        .replace('a minute ago', '1 min')
        .replace('an hour ago', '1 h')
        .replace(' hour ago', 'h')
        .replace(' hours ago', 'h')
        .replace(' day ago', 'd')
        .replace('a day ago', '1 d')
        .replace(' days ago', 'd')
        .replace('a month ago', '1 mês')
        .replace(' months ago', 'meses')
        .replace(' month ago', 'mês')
        .replace('a year ago', '1 ano')
        .replace(' year ago', 'ano')
        .replace(' years ago', 'anos');
      return convertToShortTime;
    },
  },
};
