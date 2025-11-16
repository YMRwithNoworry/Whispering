// glitch.gdshader
shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.05;
uniform float chromatic_aberration : hint_range(0.0, 20.0) = 3.0;
uniform float noise_speed : hint_range(0.0, 20.0) = 8.0;
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.15;
uniform float time = 0.0;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    
    // 随机抖动效果
    float noise = random(uv + time * noise_speed) * glitch_intensity;
    uv.x += noise * 0.02;
    uv.y += noise * 0.01;
    
    // RGB色散效果
    vec2 offset_r = vec2(chromatic_aberration * 0.001, 0.0);
    vec2 offset_b = vec2(-chromatic_aberration * 0.001, 0.0);
    
    float r = texture(screen_texture, SCREEN_UV + offset_r).r;
    float g = texture(screen_texture, SCREEN_UV).g;
    float b = texture(screen_texture, SCREEN_UV + offset_b).b;
    
    vec3 color = vec3(r, g, b);
    
    // 扫描线效果
    float scanline = sin(uv.y * 800.0) * 0.5 + 0.5;
    color -= scanline_opacity * scanline;
    
    // 轻微噪点
    float grain = random(uv + time) * 0.03;
    color += grain;
    
    COLOR = vec4(color, 1.0);
}