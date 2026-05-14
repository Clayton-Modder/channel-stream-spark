import { useState, useEffect } from "react";

export function useChromecast() {
  const [available, setAvailable] = useState(false);
  const [casting, setCasting] = useState(false);
  const [connecting, setConnecting] = useState(false);

  useEffect(() => {
    const init = (isAvailable: boolean) => {
      if (!isAvailable) return;
      const castLib = (window as any).cast;
      const chromeLib = (window as any).chrome;
      if (!castLib?.framework || !chromeLib?.cast) return;

      castLib.framework.CastContext.getInstance().setOptions({
        receiverApplicationId: chromeLib.cast.media.DEFAULT_MEDIA_RECEIVER_APP_ID,
        autoJoinPolicy: chromeLib.cast.AutoJoinPolicy.ORIGIN_SCOPED,
      });

      setAvailable(true);

      castLib.framework.CastContext.getInstance().addEventListener(
        castLib.framework.CastContextEventType.SESSION_STATE_CHANGED,
        (event: any) => {
          const { SessionState } = castLib.framework;
          const active =
            event.sessionState === SessionState.SESSION_STARTED ||
            event.sessionState === SessionState.SESSION_RESUMED;
          setCasting(active);
          setConnecting(false);
        }
      );
    };

    (window as any).__onGCastApiAvailable = init;
    // If SDK already loaded before this component mounted
    if ((window as any).cast) init(true);
  }, []);

  const castTo = async (url: string, title: string): Promise<boolean> => {
    const castLib = (window as any).cast;
    const chromeLib = (window as any).chrome;
    if (!castLib?.framework || !chromeLib?.cast) return false;

    try {
      setConnecting(true);
      const ctx = castLib.framework.CastContext.getInstance();

      if (
        ctx.getCastState() === castLib.framework.CastState.NO_DEVICES_AVAILABLE
      ) {
        setConnecting(false);
        return false;
      }

      if (ctx.getCastState() !== castLib.framework.CastState.CONNECTED) {
        await ctx.requestSession();
      }

      const session = ctx.getCurrentSession();
      if (!session) {
        setConnecting(false);
        return false;
      }

      const contentType = url.includes(".m3u8")
        ? "application/x-mpegURL"
        : "video/mp4";

      const mediaInfo = new chromeLib.cast.media.MediaInfo(url, contentType);
      mediaInfo.metadata = new chromeLib.cast.media.GenericMediaMetadata();
      mediaInfo.metadata.title = title;

      const request = new chromeLib.cast.media.LoadRequest(mediaInfo);
      await session.loadMedia(request);
      setConnecting(false);
      return true;
    } catch {
      setConnecting(false);
      return false;
    }
  };

  const stop = () => {
    const ctx = (window as any).cast?.framework?.CastContext?.getInstance();
    ctx?.getCurrentSession()?.endSession(true);
    setCasting(false);
  };

  return { available, casting, connecting, castTo, stop };
}
