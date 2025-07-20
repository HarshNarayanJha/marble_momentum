shader_type spatial;
render_mode cull_front, unshaded, world_vertex_coords;

global uniform vec4 outline_color : source_color;
instance uniform float outline_width = 0.0;
instance uniform float pulse_speed = 1.5;

void vertex() {
    float width = outline_width / 100.0;
    if (pulse_speed > 0.0) {
        float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed * TAU);
        width *= mix(0.8, 1.2, pulse);
    }

    VERTEX += NORMAL * width;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    if (outline_color.a < 1.0) {
        ALPHA = outline_color.a;
    }
}
