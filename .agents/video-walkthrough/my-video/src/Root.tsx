import React from 'react';
import { Composition } from 'remotion';
import { WalkthroughComposition } from './WalkthroughComposition';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="WalkthroughComposition"
        component={WalkthroughComposition}
        durationInFrames={450}
        fps={30}
        width={1920}
        height={1080}
      />
    </>
  );
};
