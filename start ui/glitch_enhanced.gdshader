// glitch_enhanced.gdshader
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float time = 0.0;
uniform float glitch_intensity : hint_range(0.0, 2.0) = 0.08;
uniform float chromatic_aberration : hint_range(0.0, 50.0) = 5.0;
uniform float noise_speed : hint_range(0.0, 30.0) = 12.0;
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.2;
uniform float shake_intensity : hint_range(0.0, 20.0) = 8.0;

float random2d(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 original_uv = uv;

    // 1. 强度更高的随机抖动
    float noise = random2d(uv + time * noise_speed) * glitch_intensity;
    uv.x += noise * 0.03 * shake_intensity;
    uv.y += noise * 0.015 * shake_intensity;

    // 2. RGB分离效果（色散）
    float r = texture(screen_texture, uv + vec2(chromatic_aberration * 0.002, 0.0)).r;
    float g = texture(screen_texture, uv).g;
    float b = texture(screen_texture, uv - vec2(chromatic_aberration * 0.002, 0.0)).b;
    vec3 color = vec3(r, g, b);

    // 3. 动态扫描线
    float scanline = sin(original_uv.y * 1200.0 + time * 5.0) * 0.5 + 0.5;
    color -= scanline_opacity * scanline * 0.5;

    // 4. 数字噪点
    float digital_noise = random2d(uv * 100.0 + time * 15.0) * 0.04;
    color += digital_noise;

    // 5. 间歇性黑条
    float black_bar = step(0.98, random2d(vec2(time * 0.1, uv.y * 10.0)));
    color *= (1.0 - black_bar * 0.7);

    COLOR = vec4(color, 1.0);
}