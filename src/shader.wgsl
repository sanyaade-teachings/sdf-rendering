struct VertexOutput {
    [[builtin(position)]] position: vec4<f32>;
    [[location(0)]] line_start: vec2<f32>;
    [[location(1)]] line_stop: vec2<f32>;
    [[location(2)]] vertex_position: vec2<f32>;
};


[[stage(vertex)]]
fn vs_main(
    [[location(0)]] position: vec4<f32>,
    [[location(1)]] line_start: vec2<f32>,
    [[location(2)]] line_stop: vec2<f32>,
    [[builtin(vertex_index)]] in_vertex_index: u32
) -> VertexOutput {

    var out: VertexOutput;
    out.line_start = line_start;
    out.line_stop = line_stop;
    out.position = position;
    out.vertex_position = position.xy;
    return out;
}

struct FragmentOutput {
   [[location(0)]] colors: vec4<f32>;
   [[builtin(frag_depth)]] depth: f32;
 };

struct Result{
    dist: f32;     //Regular SDF distance
    side: f32;     //Which side of the line segment the point is (-1,0,1)
};

fn ud_segment(p: vec2<f32>, a: vec2<f32>, b: vec2<f32> ) -> Result {
    var res: Result;
    //All this is basically Inigo's regular line SDF function - but store it in 'dist' instead:
    let ba = b-a;
    let pa = p-a;
    let h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    res.dist = length(pa-h*ba);
    //Is the movement (a->b->p) a righthand turn? (cross product)
    res.side = sign( (b.x - a.x)*(p.y - a.y) - (b.y - a.y)*(p.x - a.x) );
    return res;
}


[[stage(fragment)]]
fn fs_main(in: VertexOutput) -> FragmentOutput {
    var out: FragmentOutput;
    let segment = ud_segment(in.vertex_position, in.line_start, in.line_stop);
    let dist = segment.dist;
    out.depth = dist * 6.;
    let pos = (dist * 20.) % 1.;
    //out.depth = pos;
    out.colors = vec4<f32>(pos, pos, pos, 1.);
    //out.colors = vec4<f32>(1., 0., 0., 1.);

    return out;
}
