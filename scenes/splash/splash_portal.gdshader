shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform vec2 viewport_px = vec2(720.0, 1280.0);
uniform vec2 center_px = vec2(360.0, 640.0);
uniform float inner_px = 0.0;
uniform float outer_px = 0.0;
uniform float gap_center = 0.0;
uniform float gap_half = 0.4;
uniform float portal = 0.0;
uniform vec4 cream : source_color = vec4(0.965, 0.922, 0.867, 1.0);

void fragment() {
	COLOR = cream;
	if (portal >= 0.5) {
		vec2 pixel = UV * viewport_px;
		vec2 p = pixel - center_px;
		float dist = length(p);
		float ang = atan(p.y, p.x);
		float delta = atan(sin(ang - gap_center), cos(ang - gap_center));
		bool in_gap = abs(delta) < gap_half;
		if (dist < inner_px || (in_gap && dist < outer_px + 8.0)) {
			COLOR = vec4(0.0);
		}
	}
}
