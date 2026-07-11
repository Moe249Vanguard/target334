/** SVG L-shape used by NVR rotation questions. */
export function LShape({
  rotation,
  mirrored = false,
  sizeClass = 'w-12 h-12',
}: {
  rotation: number;
  mirrored?: boolean;
  sizeClass?: string;
}) {
  return (
    <svg viewBox="0 0 60 60" className={`${sizeClass} inline-block`} xmlns="http://www.w3.org/2000/svg">
      <g transform={mirrored ? 'scale(-1,1) translate(-60,0)' : undefined}>
        <polygon
          points="18,10 32,10 32,36 46,36 46,50 18,50"
          fill="#4f46e5"
          transform={`rotate(${rotation} 30 30)`}
        />
      </g>
    </svg>
  );
}
