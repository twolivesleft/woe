precision highp float;
uniform sampler2D texture;
uniform float time;

varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

// Distortion parameters
const float distortion = 0.2;
const float pixelScale = 0.000075;
const float bloomAmount = 0.35;  // Increased bloom
const float chromaticAberration = 0.0015;
const float moireFrequency = 500.0;
const float moireStrength = 0.12;
const float contrastAmount = 1.8;  // Added contrast parameter
const float brightnessBoost = 0.4;  // Added brightness boost
const float blackLevel = 0.3;      // Darkens blacks
const float horizontalScanlineIntensity = 0.04;
const float verticalScanlineIntensity = 0.125;

void main() {
    // CRT distortion - curved screen effect
    vec2 q = vTexCoord;
    vec2 uv = q;
    
    // Calculate distance from center (normalized coordinates)
    vec2 cc = q - 0.5;
    float d = dot(cc, cc) * distortion;
    
    // Apply barrel distortion
    uv = q + cc * (1.0 + d) * d;
    
    // Skip pixels outside the distorted area
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }
    
    // Chromatic aberration
    float r = texture2D(texture, uv - vec2(chromaticAberration, 0.0)).r;
    float g = texture2D(texture, uv).g;
    float b = texture2D(texture, uv + vec2(chromaticAberration, 0.0)).b;
    vec4 color = vec4(r, g, b, texture2D(texture, uv).a);
    
    // Improved pixel grid effect (RGB phosphor simulation)
    vec2 pixelCoord = fract(uv / pixelScale);
    float pixelMaskR = smoothstep(0.25, 0.35, pixelCoord.x) - smoothstep(0.65, 0.75, pixelCoord.x);
    float pixelMaskG = smoothstep(0.0, 0.1, pixelCoord.x) - smoothstep(0.4, 0.5, pixelCoord.x);
    float pixelMaskG2 = smoothstep(0.75, 0.85, pixelCoord.x) - smoothstep(0.9, 1.0, pixelCoord.x);
    float pixelMaskB = smoothstep(0.5, 0.6, pixelCoord.x) - smoothstep(0.9, 1.0, pixelCoord.x);
    
    float verticalMask = smoothstep(0.1, 0.3, pixelCoord.y) - smoothstep(0.7, 0.9, pixelCoord.y);
    float pixelMask = (pixelMaskR + pixelMaskG + pixelMaskG2 + pixelMaskB) * verticalMask;
    pixelMask = 0.85 + 0.15 * pixelMask;
    
    // Horizontal scanline effect with variable intensity
    float hScanlinePos = uv.y * 800.0 + sin(time) * 5.0;
    float hScanline = sin(hScanlinePos) * horizontalScanlineIntensity + (1.0 - horizontalScanlineIntensity);
    
    // Vertical scanline effect
    float vScanlinePos = uv.x * 1600.0 + sin(time * 0.7) * 3.0;
    float vScanline = sin(vScanlinePos) * verticalScanlineIntensity + (1.0 - verticalScanlineIntensity);
    
    // Combined scanline effect
    float scanline = hScanline * vScanline;
    
    // Moire pattern interference
    float moire = sin(uv.x * moireFrequency) * sin(uv.y * moireFrequency);
    moire = 1.0 + moire * moireStrength;
    
    // Apply contrast enhancement (before bloom)
    vec3 contrastColor = (color.rgb - 0.5) * contrastAmount + 0.5 + brightnessBoost;
    
    // Deepen the blacks
    contrastColor = max(vec3(0.0), contrastColor - vec3(blackLevel * (1.0 - dot(color.rgb, vec3(0.333)))));
    
    // Bloom/halo effect for bright areas (on the high-contrast color)
    float luminance = dot(contrastColor, vec3(0.299, 0.587, 0.114));
    float bloomThreshold = 0.7;  // Slightly lower threshold to affect more pixels
    float bloom = max(0.0, luminance - bloomThreshold) * bloomAmount;
    vec3 bloomColor = contrastColor + bloom;
    
    // Vignette effect - stronger corners for more contrast
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(q, center);
    float vignette = 1.0 - dist * 1.0;  // Increased from 0.8 to 1.0
    
    // Add a bit of noise - slightly more pronounced
    float noise = fract(sin(dot(vTexCoord, vec2(12.9898, 78.233) * time)) * 43758.5453);
    
    // Apply all effects
    gl_FragColor = vec4(bloomColor, color.a) * scanline * vignette * pixelMask * moire;
    gl_FragColor.rgb += (noise - 0.5) * 0.04;  // Increased from 0.03 to 0.04
    
    // Add a subtle old-screen flicker
    gl_FragColor.rgb *= 0.90 + 0.035 * sin(time * 8.27);
    
    // Final gamma adjustment to enhance the crunchy look
    gl_FragColor.rgb = pow(gl_FragColor.rgb, vec3(0.85));
}