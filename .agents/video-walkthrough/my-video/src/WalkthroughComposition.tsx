import React from 'react';
import { Series, AbsoluteFill } from 'remotion';
import { fade } from '@remotion/transitions/fade';
import { TransitionSeries, linearTiming } from '@remotion/transitions';
import { ScreenSlide } from './ScreenSlide';

const screens = [
  {
    title: "La Ceremonia de Selección",
    description: "Una inmersión profunda en el misticismo de Hogwarts a través de maximalismo sustractivo.",
    imageSrc: "../public/assets/screens/click_feedback_1771605372541.png",
    duration: 120
  },
  {
    title: "El Ritmo del Ritual",
    description: "Cada incisión revela una parte de tu alma con interacciones físicas y estados magnéticos.",
    imageSrc: "../public/assets/screens/click_feedback_1771605418899.png",
    duration: 120
  },
  {
    title: "Avance Progresivo",
    description: "Inquisición tras inquisición el progreso avanza revelando tu destino latente.",
    imageSrc: "../public/assets/screens/click_feedback_1771605453652.png",
    duration: 120
  },
  {
    title: "Decisiones que Pesan",
    description: "Hover states y placas de selección levitantes elevan la gravedad de tus elecciones.",
    imageSrc: "../public/assets/screens/click_feedback_1771605505132.png",
    duration: 150
  }
];

export const WalkthroughComposition: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: '#050303' }}>
      <TransitionSeries>
        {screens.map((screen, index) => {
          return (
            <React.Fragment key={index}>
              <TransitionSeries.Sequence durationInFrames={screen.duration}>
                <ScreenSlide 
                  title={screen.title} 
                  description={screen.description} 
                  imageSrc={screen.imageSrc} 
                />
              </TransitionSeries.Sequence>
              {index < screens.length - 1 && (
                <TransitionSeries.Transition
                  presentation={fade()}
                  timing={linearTiming({ durationInFrames: 30 })}
                />
              )}
            </React.Fragment>
          );
        })}
      </TransitionSeries>
    </AbsoluteFill>
  );
};
