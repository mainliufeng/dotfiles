import type React from 'react';
import {Composition} from 'remotion';
import {HyprlandSkillIntro} from './hyprland-skill-intro';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="HyprlandSkillIntro"
        component={HyprlandSkillIntro}
        durationInFrames={600}
        fps={30}
        width={1920}
        height={1080}
      />
    </>
  );
};
