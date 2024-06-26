shader_type canvas_item;

uniform float width : hint_range(0.0, 10.0, 0.1);
uniform vec4 ouline_color : source_color; 

void fragment() {
	float size = width * 1.0 / float(textureSize(TEXTURE, 0).x);
	vec4 sprite_color = texture(TEXTURE, UV);
	float alpha = -4.0 * sprite_color.a;
	alpha += texture(TEXTURE, UV + vec2(size, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(-size, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(0, size)).a;
	alpha += texture(TEXTURE, UV + vec2(0, -size)).a;
	
	vec4 final_color = mix(sprite_color, ouline_color, clamp(alpha, 0.0, 1.0));
	COLOR = vec4(final_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));
	
	
}
