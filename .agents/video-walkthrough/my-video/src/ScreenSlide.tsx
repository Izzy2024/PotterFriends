import React from 'react';
import { AbsoluteFill, useCurrentFrame, spring, useVideoConfig, interpolate } from 'remotion';

export const ScreenSlide: React.FC<{
  imageSrc: string;
  title: string;
  description: string;
}> = ({ imageSrc, title, description }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Animate the image scale
  const scale = spring({
    fps,
    frame,
    config: { damping: 200 },
  });

  // Calculate actual scale ranging from 1.0 to 1.05
  const actualScale = interpolate(scale, [0, 1], [1, 1.05]);

  // Fade in animation for text
  const opacity = interpolate(Math.max(0, frame - 15), [0, 30], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill style={{ backgroundColor: '#050303' }}>
      <AbsoluteFill style={{ display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
        {/* En caso de que las imagenes aun no esten copiadas, mostrar un placeholder estetico */}
        <div 
           style={{ 
             width: '100%', 
             height: '100%', 
             backgroundImage: `url(${imageSrc})`, 
             backgroundSize: 'cover', 
             backgroundPosition: 'center',
             transform: `scale(${actualScale})`,
             opacity: 0.8
           }} 
        />
        <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(to top, rgba(5,3,3,1), transparent)' }} />
      </AbsoluteFill>

      <AbsoluteFill style={{ justifyContent: 'flex-end', padding: '100px', opacity }}>
        <h1 style={{ fontFamily: 'Cinzel, serif', fontSize: '80px', color: '#ECE1CD', margin: 0, textShadow: '0 4px 20px rgba(0,0,0,0.8)' }}>
          {title}
        </h1>
        <p style={{ fontFamily: 'EB Garamond, serif', fontSize: '40px', color: '#8A8172', marginTop: '20px', maxWidth: '1200px' }}>
          {description}
        </p>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
