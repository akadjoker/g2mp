unit G2OpenGLES11;

interface

uses
  G2Utils;

const
  LibGLES = 'libGLESv1_CM.so';

type
  TGLenum = LongWord;
  TGLboolean = Boolean;
  TGLbitfield = LongWord;
  TGLbyte = ShortInt;
  TGLshort = SmallInt;
  TGLint = Integer;
  TGLuint = LongWord;
  TGLsizei = Integer;
  TGLubyte = Byte;
  TGLushort = Word;
  TGLfloat = Single;
  TGLclampf = Single;
  TGLdouble = Double;
  TGLclampd = Double;
  TGLvoid = Pointer;
  TGLint64 = Int64;
  TGLfixed = LongInt;
  TGLclampx = LongInt;
  TGLsizeiptr = sizeint;

  GLenum = TGLenum;
  GLboolean = TGLboolean;
  GLbitfield = TGLbitfield;
  GLbyte = TGLbyte;
  GLshort = TGLshort;
  GLint = TGLint;
  GLuint = TGLuint;
  GLsizei = TGLsizei;
  GLubyte = TGLubyte;
  GLushort = TGLushort;
  GLfloat = TGLfloat;
  GLclampf = TGLclampf;
  GLdouble = TGLdouble;
  GLclampd = TGLclampd;
  GLvoid = TGLvoid;
  GLint64 = TGLint64;
  GLfixed = TGLfixed;
  GLclampx = TGLclampx;
  GLsizeiptr = TGLsizeiptr;

  PGLBoolean = ^TGLboolean;
  PGLByte = ^TGLbyte;
  PGLShort = ^TGLshort;
  PGLInt = ^TGLint;
  PGLSizei = ^TGLsizei;
  PGLubyte = ^TGLubyte;
  PGLushort = ^TGLushort;
  PGLuint = ^TGLuint;
  PGLclampf = ^TGLclampf;
  PGLfloat = ^TGLfloat;
  PGLdouble = ^TGLdouble;
  PGLclampd = ^TGLclampd;
  PGLenum = ^TGLenum;
  PGLvoid = Pointer;
  PGLint64 = ^TGLint64;
  PGLfixed = ^TGLfixed;
  PGLclampx = ^GLclampx;
  PGLsizeiptr = ^GLsizeiptr;

const
  GL_VERSION_ES_CM_1_0 = 1;
  GL_VERSION_ES_CL_1_0 = 1;
  GL_VERSION_ES_CM_1_1 = 1;
  GL_VERSION_ES_CL_1_1 = 1;

  GL_DEPTH_BUFFER_BIT = $00000100;
  GL_STENCIL_BUFFER_BIT = $00000400;
  GL_COLOR_BUFFER_BIT = $00004000;

  GL_FALSE = 0;
  GL_TRUE = 1;

  GL_POINTS = $0000;
  GL_LINES = $0001;
  GL_LINE_LOOP = $0002;
  GL_LINE_STRIP = $0003;
  GL_TRIANGLES = $0004;
  GL_TRIANGLE_STRIP = $0005;
  GL_TRIANGLE_FAN = $0006;

  GL_NEVER = $0200;
  GL_LESS = $0201;
  GL_EQUAL = $0202;
  GL_LEQUAL = $0203;
  GL_GREATER = $0204;
  GL_NOTEQUAL = $0205;
  GL_GEQUAL = $0206;
  GL_ALWAYS = $0207;

  GL_ZERO = 0;
  GL_ONE = 1;
  GL_SRC_COLOR = $0300;
  GL_ONE_MINUS_SRC_COLOR = $0301;
  GL_SRC_ALPHA = $0302;
  GL_ONE_MINUS_SRC_ALPHA = $0303;
  GL_DST_ALPHA = $0304;
  GL_ONE_MINUS_DST_ALPHA = $0305;

  GL_DST_COLOR = $0306;
  GL_ONE_MINUS_DST_COLOR = $0307;
  GL_SRC_ALPHA_SATURATE = $0308;

  GL_CLIP_PLANE0 = $3000;
  GL_CLIP_PLANE1 = $3001;
  GL_CLIP_PLANE2 = $3002;
  GL_CLIP_PLANE3 = $3003;
  GL_CLIP_PLANE4 = $3004;
  GL_CLIP_PLANE5 = $3005;

  GL_FRONT = $0404;
  GL_BACK = $0405;
  GL_FRONT_AND_BACK = $0408;

  GL_FOG = $0B60;
  GL_LIGHTING = $0B50;
  GL_TEXTURE_2D = $0DE1;
  GL_CULL_FACE = $0B44;
  GL_ALPHA_TEST = $0BC0;
  GL_BLEND = $0BE2;
  GL_COLOR_LOGIC_OP = $0BF2;
  GL_DITHER = $0BD0;
  GL_STENCIL_TEST = $0B90;
  GL_DEPTH_TEST = $0B71;

  GL_POINT_SMOOTH = $0B10;
  GL_LINE_SMOOTH = $0B20;
  GL_SCISSOR_TEST = $0C11;
  GL_COLOR_MATERIAL = $0B57;
  GL_NORMALIZE = $0BA1;
  GL_RESCALE_NORMAL = $803A;
  GL_POLYGON_OFFSET_FILL = $8037;
  GL_VERTEX_ARRAY = $8074;
  GL_NORMAL_ARRAY = $8075;
  GL_COLOR_ARRAY = $8076;
  GL_TEXTURE_COORD_ARRAY = $8078;
  GL_MULTISAMPLE = $809D;
  GL_SAMPLE_ALPHA_TO_COVERAGE = $809E;
  GL_SAMPLE_ALPHA_TO_ONE = $809F;
  GL_SAMPLE_COVERAGE = $80A0;

  GL_NO_ERROR = 0;
  GL_INVALID_ENUM = $0500;
  GL_INVALID_VALUE = $0501;
  GL_INVALID_OPERATION = $0502;
  GL_STACK_OVERFLOW = $0503;
  GL_STACK_UNDERFLOW = $0504;
  GL_OUT_OF_MEMORY = $0505;

  GL_EXP = $0800;
  GL_EXP2 = $0801;

  GL_FOG_DENSITY = $0B62;
  GL_FOG_START = $0B63;
  GL_FOG_END = $0B64;
  GL_FOG_MODE = $0B65;
  GL_FOG_COLOR = $0B66;

  GL_CW = $0900;
  GL_CCW = $0901;

  GL_CURRENT_COLOR = $0B00;
  GL_CURRENT_NORMAL = $0B02;
  GL_CURRENT_TEXTURE_COORDS = $0B03;
  GL_POINT_SIZE = $0B11;
  GL_POINT_SIZE_MIN = $8126;
  GL_POINT_SIZE_MAX = $8127;
  GL_POINT_FADE_THRESHOLD_SIZE = $8128;
  GL_POINT_DISTANCE_ATTENUATION = $8129;
  GL_SMOOTH_POINT_SIZE_RANGE = $0B12;
  GL_LINE_WIDTH = $0B21;
  GL_SMOOTH_LINE_WIDTH_RANGE = $0B22;
  GL_ALIASED_POINT_SIZE_RANGE = $846D;
  GL_ALIASED_LINE_WIDTH_RANGE = $846E;
  GL_CULL_FACE_MODE = $0B45;
  GL_FRONT_FACE = $0B46;
  GL_SHADE_MODEL = $0B54;
  GL_DEPTH_RANGE = $0B70;
  GL_DEPTH_WRITEMASK = $0B72;
  GL_DEPTH_CLEAR_VALUE = $0B73;
  GL_DEPTH_FUNC = $0B74;
  GL_STENCIL_CLEAR_VALUE = $0B91;
  GL_STENCIL_FUNC = $0B92;
  GL_STENCIL_VALUE_MASK = $0B93;
  GL_STENCIL_FAIL = $0B94;
  GL_STENCIL_PASS_DEPTH_FAIL = $0B95;
  GL_STENCIL_PASS_DEPTH_PASS = $0B96;
  GL_STENCIL_REF = $0B97;
  GL_STENCIL_WRITEMASK = $0B98;
  GL_MATRIX_MODE = $0BA0;
  GL_VIEWPORT = $0BA2;
  GL_MODELVIEW_STACK_DEPTH = $0BA3;
  GL_PROJECTION_STACK_DEPTH = $0BA4;
  GL_TEXTURE_STACK_DEPTH = $0BA5;
  GL_MODELVIEW_MATRIX = $0BA6;
  GL_PROJECTION_MATRIX = $0BA7;
  GL_TEXTURE_MATRIX = $0BA8;
  GL_ALPHA_TEST_FUNC = $0BC1;
  GL_ALPHA_TEST_REF = $0BC2;
  GL_BLEND_DST = $0BE0;
  GL_BLEND_SRC = $0BE1;
  GL_LOGIC_OP_MODE = $0BF0;
  GL_SCISSOR_BOX = $0C10;
  GL_COLOR_CLEAR_VALUE = $0C22;
  GL_COLOR_WRITEMASK = $0C23;
  GL_UNPACK_ALIGNMENT = $0CF5;
  GL_PACK_ALIGNMENT = $0D05;
  GL_MAX_LIGHTS = $0D31;
  GL_MAX_CLIP_PLANES = $0D32;
  GL_MAX_TEXTURE_SIZE = $0D33;
  GL_MAX_MODELVIEW_STACK_DEPTH = $0D36;
  GL_MAX_PROJECTION_STACK_DEPTH = $0D38;
  GL_MAX_TEXTURE_STACK_DEPTH = $0D39;
  GL_MAX_VIEWPORT_DIMS = $0D3A;
  GL_MAX_TEXTURE_UNITS = $84E2;
  GL_SUBPIXEL_BITS = $0D50;
  GL_RED_BITS = $0D52;
  GL_GREEN_BITS = $0D53;
  GL_BLUE_BITS = $0D54;
  GL_ALPHA_BITS = $0D55;
  GL_DEPTH_BITS = $0D56;
  GL_STENCIL_BITS = $0D57;
  GL_POLYGON_OFFSET_UNITS = $2A00;
  GL_POLYGON_OFFSET_FACTOR = $8038;
  GL_TEXTURE_BINDING_2D = $8069;
  GL_VERTEX_ARRAY_SIZE = $807A;
  GL_VERTEX_ARRAY_TYPE = $807B;
  GL_VERTEX_ARRAY_STRIDE = $807C;
  GL_NORMAL_ARRAY_TYPE = $807E;
  GL_NORMAL_ARRAY_STRIDE = $807F;
  GL_COLOR_ARRAY_SIZE = $8081;
  GL_COLOR_ARRAY_TYPE = $8082;
  GL_COLOR_ARRAY_STRIDE = $8083;
  GL_TEXTURE_COORD_ARRAY_SIZE = $8088;
  GL_TEXTURE_COORD_ARRAY_TYPE = $8089;
  GL_TEXTURE_COORD_ARRAY_STRIDE = $808A;
  GL_VERTEX_ARRAY_POINTER = $808E;
  GL_NORMAL_ARRAY_POINTER = $808F;
  GL_COLOR_ARRAY_POINTER = $8090;
  GL_TEXTURE_COORD_ARRAY_POINTER = $8092;
  GL_SAMPLE_BUFFERS = $80A8;
  GL_SAMPLES = $80A9;
  GL_SAMPLE_COVERAGE_VALUE = $80AA;
  GL_SAMPLE_COVERAGE_INVERT = $80AB;

  GL_NUM_COMPRESSED_TEXTURE_FORMATS = $86A2;
  GL_COMPRESSED_TEXTURE_FORMATS = $86A3;

  GL_DONT_CARE = $1100;
  GL_FASTEST = $1101;
  GL_NICEST = $1102;

  GL_PERSPECTIVE_CORRECTION_HINT = $0C50;
  GL_POINT_SMOOTH_HINT = $0C51;
  GL_LINE_SMOOTH_HINT = $0C52;
  GL_FOG_HINT = $0C54;
  GL_GENERATE_MIPMAP_HINT = $8192;

  GL_LIGHT_MODEL_AMBIENT = $0B53;
  GL_LIGHT_MODEL_TWO_SIDE = $0B52;

  GL_AMBIENT = $1200;
  GL_DIFFUSE = $1201;
  GL_SPECULAR = $1202;
  GL_POSITION = $1203;
  GL_SPOT_DIRECTION = $1204;
  GL_SPOT_EXPONENT = $1205;
  GL_SPOT_CUTOFF = $1206;
  GL_CONSTANT_ATTENUATION = $1207;
  GL_LINEAR_ATTENUATION = $1208;
  GL_QUADRATIC_ATTENUATION = $1209;

  GL_BYTE = $1400;
  GL_UNSIGNED_BYTE = $1401;
  GL_SHORT = $1402;
  GL_UNSIGNED_SHORT = $1403;
  GL_FLOAT = $1406;
  GL_FIXED = $140C;

  GL_CLEAR = $1500;
  GL_AND = $1501;
  GL_AND_REVERSE = $1502;
  GL_COPY = $1503;
  GL_AND_INVERTED = $1504;
  GL_NOOP = $1505;
  GL_XOR = $1506;
  GL_OR = $1507;
  GL_NOR = $1508;
  GL_EQUIV = $1509;
  GL_INVERT = $150A;
  GL_OR_REVERSE = $150B;
  GL_COPY_INVERTED = $150C;
  GL_OR_INVERTED = $150D;
  GL_NAND = $150E;
  GL_SET = $150F;

  GL_EMISSION = $1600;
  GL_SHININESS = $1601;
  GL_AMBIENT_AND_DIFFUSE = $1602;

  GL_MODELVIEW = $1700;
  GL_PROJECTION = $1701;
  GL_TEXTURE = $1702;

  GL_ALPHA = $1906;
  GL_RGB = $1907;
  GL_RGBA = $1908;
  GL_LUMINANCE = $1909;
  GL_LUMINANCE_ALPHA = $190A;

  GL_UNSIGNED_SHORT_4_4_4_4 = $8033;
  GL_UNSIGNED_SHORT_5_5_5_1 = $8034;
  GL_UNSIGNED_SHORT_5_6_5 = $8363;

  GL_FLAT = $1D00;
  GL_SMOOTH = $1D01;

  GL_KEEP = $1E00;
  GL_REPLACE = $1E01;
  GL_INCR = $1E02;
  GL_DECR = $1E03;

  GL_VENDOR = $1F00;
  GL_RENDERER = $1F01;
  GL_VERSION = $1F02;
  GL_EXTENSIONS = $1F03;

  GL_MODULATE = $2100;
  GL_DECAL = $2101;

  GL_ADD = $0104;

  GL_TEXTURE_ENV_MODE = $2200;
  GL_TEXTURE_ENV_COLOR = $2201;

  GL_TEXTURE_ENV = $2300;

  GL_NEAREST = $2600;
  GL_LINEAR = $2601;

  GL_NEAREST_MIPMAP_NEAREST = $2700;
  GL_LINEAR_MIPMAP_NEAREST = $2701;
  GL_NEAREST_MIPMAP_LINEAR = $2702;
  GL_LINEAR_MIPMAP_LINEAR = $2703;

  GL_TEXTURE_MAG_FILTER = $2800;
  GL_TEXTURE_MIN_FILTER = $2801;
  GL_TEXTURE_WRAP_S = $2802;
  GL_TEXTURE_WRAP_T = $2803;
  GL_GENERATE_MIPMAP = $8191;

  GL_TEXTURE0 = $84C0;
  GL_TEXTURE1 = $84C1;
  GL_TEXTURE2 = $84C2;
  GL_TEXTURE3 = $84C3;
  GL_TEXTURE4 = $84C4;
  GL_TEXTURE5 = $84C5;
  GL_TEXTURE6 = $84C6;
  GL_TEXTURE7 = $84C7;
  GL_TEXTURE8 = $84C8;
  GL_TEXTURE9 = $84C9;
  GL_TEXTURE10 = $84CA;
  GL_TEXTURE11 = $84CB;
  GL_TEXTURE12 = $84CC;
  GL_TEXTURE13 = $84CD;
  GL_TEXTURE14 = $84CE;
  GL_TEXTURE15 = $84CF;
  GL_TEXTURE16 = $84D0;
  GL_TEXTURE17 = $84D1;
  GL_TEXTURE18 = $84D2;
  GL_TEXTURE19 = $84D3;
  GL_TEXTURE20 = $84D4;
  GL_TEXTURE21 = $84D5;
  GL_TEXTURE22 = $84D6;
  GL_TEXTURE23 = $84D7;
  GL_TEXTURE24 = $84D8;
  GL_TEXTURE25 = $84D9;
  GL_TEXTURE26 = $84DA;
  GL_TEXTURE27 = $84DB;
  GL_TEXTURE28 = $84DC;
  GL_TEXTURE29 = $84DD;
  GL_TEXTURE30 = $84DE;
  GL_TEXTURE31 = $84DF;
  GL_ACTIVE_TEXTURE = $84E0;
  GL_CLIENT_ACTIVE_TEXTURE = $84E1;

  GL_REPEAT = $2901;
  GL_CLAMP_TO_EDGE = $812F;

  GL_LIGHT0 = $4000;
  GL_LIGHT1 = $4001;
  GL_LIGHT2 = $4002;
  GL_LIGHT3 = $4003;
  GL_LIGHT4 = $4004;
  GL_LIGHT5 = $4005;
  GL_LIGHT6 = $4006;
  GL_LIGHT7 = $4007;

  GL_ARRAY_BUFFER = $8892;
  GL_ELEMENT_ARRAY_BUFFER = $8893;
  GL_ARRAY_BUFFER_BINDING = $8894;
  GL_ELEMENT_ARRAY_BUFFER_BINDING = $8895;
  GL_VERTEX_ARRAY_BUFFER_BINDING = $8896;
  GL_NORMAL_ARRAY_BUFFER_BINDING = $8897;
  GL_COLOR_ARRAY_BUFFER_BINDING = $8898;
  GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING = $889A;
  GL_STATIC_DRAW = $88E4;
  GL_DYNAMIC_DRAW = $88E8;
  GL_BUFFER_SIZE = $8764;
  GL_BUFFER_USAGE = $8765;

  GL_SUBTRACT = $84E7;
  GL_COMBINE = $8570;
  GL_COMBINE_RGB = $8571;
  GL_COMBINE_ALPHA = $8572;
  GL_RGB_SCALE = $8573;
  GL_ADD_SIGNED = $8574;
  GL_INTERPOLATE = $8575;
  GL_CONSTANT = $8576;
  GL_PRIMARY_COLOR = $8577;
  GL_PREVIOUS = $8578;
  GL_SOURCE0_RGB = $8580;
  GL_SOURCE1_RGB = $8581;
  GL_SOURCE2_RGB = $8582;
  GL_SOURCE0_ALPHA = $8588;
  GL_SOURCE1_ALPHA = $8589;
  GL_SOURCE2_ALPHA = $858A;
  GL_OPERAND0_RGB = $8590;
  GL_OPERAND1_RGB = $8591;
  GL_OPERAND2_RGB = $8592;
  GL_OPERAND0_ALPHA = $8598;
  GL_OPERAND1_ALPHA = $8599;
  GL_OPERAND2_ALPHA = $859A;
  GL_ALPHA_SCALE = $0D1C;
  GL_SRC0_RGB = $8580;
  GL_SRC1_RGB = $8581;
  GL_SRC2_RGB = $8582;
  GL_SRC0_ALPHA = $8588;
  GL_SRC1_ALPHA = $8589;
  GL_SRC2_ALPHA = $858A;
  GL_DOT3_RGB = $86AE;
  GL_DOT3_RGBA = $86AF;

  GL_IMPLEMENTATION_COLOR_READ_TYPE_OES = $8B9A;
  GL_IMPLEMENTATION_COLOR_READ_FORMAT_OES = $8B9B;

  GL_PALETTE4_RGB8_OES = $8B90;
  GL_PALETTE4_RGBA8_OES = $8B91;
  GL_PALETTE4_R5_G6_B5_OES = $8B92;
  GL_PALETTE4_RGBA4_OES = $8B93;
  GL_PALETTE4_RGB5_A1_OES = $8B94;
  GL_PALETTE8_RGB8_OES = $8B95;
  GL_PALETTE8_RGBA8_OES = $8B96;
  GL_PALETTE8_R5_G6_B5_OES = $8B97;
  GL_PALETTE8_RGBA4_OES = $8B98;
  GL_PALETTE8_RGB5_A1_OES = $8B99;

  GL_POINT_SIZE_ARRAY_OES = $8B9C;
  GL_POINT_SIZE_ARRAY_TYPE_OES = $898A;
  GL_POINT_SIZE_ARRAY_STRIDE_OES = $898B;
  GL_POINT_SIZE_ARRAY_POINTER_OES = $898C;

  GL_POINT_SPRITE_OES = $8861;
  GL_COORD_REPLACE_OES = $8862;

  GL_FRAMEBUFFER_OES = $8D40;
  GL_RENDERBUFFER_OES = $8D41;
  GL_DEPTH_COMPONENT16_OES = $81A5;
  GL_DEPTH_COMPONENT24_OES = $81A6;
  GL_DEPTH_COMPONENT32_OES = $81A7;
  GL_COLOR_ATTACHMENT0_OES = $8CE0;
  GL_DEPTH_ATTACHMENT_OES = $8D00;
  GL_MAX_RENDERBUFFER_SIZE_OES = $84E8;

  GL_OES_read_format = 1;
  GL_OES_compressed_paletted_texture = 1;
  GL_OES_point_size_array = 1;
  GL_OES_point_sprite = 1;

procedure glAlphaFunc(func: GLenum; ref: GLclampf); cdecl; external LibGLES;
procedure glClearColor(red, green, blue, alpha: GLclampf); cdecl; external LibGLES;
procedure glClearDepthf(depth: GLclampf); cdecl; external LibGLES;
procedure glClipPlanef(plane: GLenum; equation: PGLfloat); cdecl; external LibGLES;
procedure glColor4f(red, green, blue, alpha: GLfloat); cdecl; external LibGLES;
procedure glDepthRangef(zNear, zFar: GLclampf); cdecl; external LibGLES;
procedure glFogf(pname: GLenum; param: GLfloat); cdecl; external LibGLES;
procedure glFogfv(pname: GLenum; params: PGLfloat); cdecl; external LibGLES;
procedure glFrustumf(left, right, bottom, top, zNear, zFar: GLfloat); cdecl; external LibGLES;
procedure glGetClipPlanef(pname: GLenum; eqn: GLfloat); cdecl; external LibGLES;
procedure glGetFloatv(pname: GLenum; params: PGLfloat); cdecl; external LibGLES;
procedure glGetLightfv(light, pname: GLenum; params: PGLfloat); cdecl; external LibGLES;
procedure glGetMaterialfv(face, pname: GLenum; params: PGLfloat); cdecl; external LibGLES;
procedure glGetTexEnvfv(env, pname: GLenum; params: PGLfloat); cdecl; external LibGLES;
procedure glGetTexParameterfv(target, pname: GLenum; params: PGLfloat); cdecl; external LibGLES;
procedure glLightModelf(pname: GLenum; param: GLfloat); cdecl; external LibGLES;
procedure glLightModelfv(pname: GLenum; params: PGLfloat); cdecl; external LibGLES;
procedure glLightf(light, pname: GLenum; param: GLfloat); cdecl; external LibGLES;
procedure glLightfv(light, pname: GLenum; params: PGLfloat); cdecl; external LibGLES;
procedure glLineWidth(width: GLfloat); cdecl; external LibGLES;
procedure glLoadMatrixf(m: PGLfloat); cdecl; external LibGLES;
procedure glMaterialf(face, pname: GLenum; param: GLfloat); cdecl; external LibGLES;
procedure glMaterialfv(face, pname: GLenum; params: PGLfloat); cdecl; external LibGLES;
procedure glMultMatrixf(m: PGLfloat); cdecl; external LibGLES;
procedure glMultiTexCoord4f(target: GLenum; s, t, r, q: GLfloat); cdecl; external LibGLES;
procedure glNormal3f(nx, ny, nz: GLfloat); cdecl; external LibGLES;
procedure glOrthof(left, right, bottom, top, zNear, zFar: GLfloat); cdecl; external LibGLES;
procedure glPointParameterf(pname: GLenum; param: GLfloat); cdecl; external LibGLES;
procedure glPointParameterfv(pname: GLenum; params: PGLfloat); cdecl; external LibGLES;
procedure glPointSize(size: GLfloat); cdecl; external LibGLES;
procedure glPolygonOffset(factor, units: GLfloat); cdecl; external LibGLES;
procedure glRotatef(angle, x, y, z: GLfloat); cdecl; external LibGLES;
procedure glScalef(x, y, z: GLfloat); cdecl; external LibGLES;
procedure glTexEnvf(target, pname: GLenum; param: GLfloat); cdecl; external LibGLES;
procedure glTexEnvfv(target, pname: GLenum; params: PGLfloat); cdecl; external LibGLES;
procedure glTexParameterf(target, pname: GLenum; param: GLfloat); cdecl; external LibGLES;
procedure glTexParameterfv(target, pname: GLenum; params: PGLfloat); cdecl; external LibGLES;
procedure glTranslatef(x, y, z: GLfloat); cdecl; external LibGLES;
procedure glActiveTexture(texture: GLenum); cdecl; external LibGLES;
procedure glAlphaFuncx(func: GLenum; ref: GLclampx); cdecl; external LibGLES;
procedure glBindBuffer(target: GLenum; buffer: GLuint); cdecl; external LibGLES;
procedure glBindTexture(target: GLenum; texture: GLuint); cdecl; external LibGLES;
procedure glBlendFunc(sfactor, dfactor: GLenum); cdecl; external LibGLES;
procedure glBufferData(target: GLenum; size: GLsizeiptr; data: PGLvoid; usage: GLenum); cdecl; external LibGLES;
procedure glBufferSubData(target: GLenum; offset: PGLint; size: GLsizeiptr; data: PGLvoid); cdecl; external LibGLES;
procedure glClear(mask: GLbitfield); cdecl; external LibGLES;
procedure glClearColorx(red, green, blue, alpha: GLclampx); cdecl; external LibGLES;
procedure glClearDepthx(depth: GLclampx); cdecl; external LibGLES;
procedure glClearStencil(s: GLint); cdecl; external LibGLES;
procedure glClientActiveTexture(texture: GLenum); cdecl; external LibGLES;
procedure glClipPlanex(plane: GLenum; equation: PGLfixed); cdecl; external LibGLES;
procedure glColor4ub(red, green, blue, alpha: GLubyte); cdecl; external LibGLES;
procedure glColor4x(red, green, blue, alpha: GLfixed); cdecl; external LibGLES;
procedure glColorMask(red, green, blue, alpha: GLboolean); cdecl; external LibGLES;
procedure glColorPointer(size: GLint; type_: GLenum; stride: GLsizei; pointer: PGLvoid); cdecl; external LibGLES;
procedure glCompressedTexImage2D(target: GLenum; level: GLint; internalformat: GLenum; width, height: GLsizei; border: GLint; imageSize: GLsizei; data: PGLvoid); cdecl; external LibGLES;
procedure glCompressedTexSubImage2D(target: GLenum;level, xoffset, yoffset: GLint; width, height: GLsizei; format: GLenum;imageSize: GLsizei; data: PGLvoid); cdecl; external LibGLES;
procedure glCopyTexImage2D(target: GLenum; level: GLint; internalformat: GLenum; x, y: GLint; width, height: GLsizei; border: GLint); cdecl; external LibGLES;
procedure glCopyTexSubImage2D(target: GLenum; level, xoffset, yoffset, x, y: GLint; width, height: GLsizei); cdecl; external LibGLES;
procedure glCullFace(mode: GLenum); cdecl; external LibGLES;
procedure glDeleteBuffers(n: GLsizei; buffers: PGLuint); cdecl; external LibGLES;
procedure glDeleteTextures(n: GLsizei; textures: PGLuint); cdecl; external LibGLES;
procedure glDepthFunc(func: GLenum); cdecl; external LibGLES;
procedure glDepthMask(flag: GLboolean); cdecl; external LibGLES;
procedure glDepthRangex(zNear, zFar: GLclampx); cdecl; external LibGLES;
procedure glDisable(cap: GLenum); cdecl; external LibGLES;
procedure glDisableClientState(array_: GLenum); cdecl; external LibGLES;
procedure glDrawArrays(mode: GLenum; first: GLint; count: GLsizei); cdecl; external LibGLES;
procedure glDrawElements(mode: GLenum; count: GLsizei; type_: GLenum; indices: PGLvoid); cdecl; external LibGLES;
procedure glEnable(cap: GLenum); cdecl; external LibGLES;
procedure glEnableClientState(array_: GLenum); cdecl; external LibGLES;
procedure glFinish; cdecl; external LibGLES;
procedure glFlush; cdecl; external LibGLES;
procedure glFogx(pname: GLenum; param: GLfixed); cdecl; external LibGLES;
procedure glFogxv(pname: GLenum; params: PGLfixed); cdecl; external LibGLES;
procedure glFrontFace(mode: GLenum); cdecl; external LibGLES;
procedure glFrustumx(left, right, bottom, top, zNear, zFar: GLfixed); cdecl; external LibGLES;
procedure glGetBooleanv(pname: GLenum; params: PGLboolean); cdecl; external LibGLES;
procedure glGetBufferParameteriv(target, pname: GLenum; params: PGLint); cdecl; external LibGLES;
procedure glGetClipPlanex(pname: GLenum; eqn: GLfixed); cdecl; external LibGLES;
procedure glGenBuffers(n: GLsizei; buffers: PGLuint); cdecl; external LibGLES;
procedure glGenTextures(n: GLsizei; textures: PGLuint); cdecl; external LibGLES;
function glGetError: GLenum; cdecl; external LibGLES;
procedure glGetFixedv(pname: GLenum; params: PGLfixed); cdecl; external LibGLES;
procedure glGetIntegerv(pname: GLenum; params: PGLint); cdecl; external LibGLES;
procedure glGetLightxv(light, pname: GLenum; params: PGLfixed); cdecl; external LibGLES;
procedure glGetMaterialxv(face, pname: GLenum; params: PGLfixed); cdecl; external LibGLES;
procedure glGetPointerv(pname: GLenum; params: PPointer); cdecl; external LibGLES;
function glGetString(name_: GLenum): PGLubyte; cdecl; external LibGLES;
procedure glGetTexEnviv(env, pname: GLenum; params: PGLint); cdecl; external LibGLES;
procedure glGetTexEnvxv(env, pname: GLenum; params: PGLfixed); cdecl; external LibGLES;
procedure glGetTexParameteriv(target, pname: GLenum; params: PGLint); cdecl; external LibGLES;
procedure glGetTexParameterxv(target, pname: GLenum; params: PGLfixed); cdecl; external LibGLES;
procedure glHint(target, mode: GLenum); cdecl; external LibGLES;
function glIsBuffer(buffer: GLuint): GLboolean; cdecl; external LibGLES;
function glIsEnabled(cap: GLenum): GLboolean; cdecl; external LibGLES;
function glIsTexture(texture: GLuint): GLboolean; cdecl; external LibGLES;
procedure glLightModelx(pname: GLenum; param: GLfixed); cdecl; external LibGLES;
procedure glLightModelxv(pname: GLenum; params: PGLfixed); cdecl; external LibGLES;
procedure glLightx(light, pname: GLenum; param: GLfixed); cdecl; external LibGLES;
procedure glLightxv(light, pname: GLenum; params: PGLfixed); cdecl; external LibGLES;
procedure glLineWidthx(width: GLfixed); cdecl; external LibGLES;
procedure glLoadIdentity; cdecl; external LibGLES;
procedure glLoadMatrixx(m: PGLfixed); cdecl; external LibGLES;
procedure glLogicOp(opcode: GLenum); cdecl; external LibGLES;
procedure glMaterialx(face, pname: GLenum; param: GLfixed); cdecl; external LibGLES;
procedure glMaterialxv(face, pname: GLenum; params: PGLfixed); cdecl; external LibGLES;
procedure glMatrixMode(mode: GLenum); cdecl; external LibGLES;
procedure glMultMatrixx(m: PGLfixed); cdecl; external LibGLES;
procedure glMultiTexCoord4x(target: GLenum; s, t, r, q: GLfixed); cdecl; external LibGLES;
procedure glNormal3x(nx, ny, nz: GLfixed); cdecl; external LibGLES;
procedure glNormalPointer(type_: GLenum; stride: GLsizei; pointer: PGLvoid); cdecl; external LibGLES;
procedure glOrthox(left, right, bottom, top, zNear, zFar: GLfixed); cdecl; external LibGLES;
procedure glPixelStorei(pname: GLenum; param: GLint); cdecl; external LibGLES;
procedure glPointParameterx(pname: GLenum; param: GLfixed); cdecl; external LibGLES;
procedure glPointParameterxv(pname: GLenum; params: PGLfixed); cdecl; external LibGLES;
procedure glPointSizex(size: GLfixed); cdecl; external LibGLES;
procedure glPolygonOffsetx(factor, units: GLfixed); cdecl; external LibGLES;
procedure glPopMatrix; cdecl; external LibGLES;
procedure glPushMatrix; cdecl; external LibGLES;
procedure glReadPixels(x, y: GLint; width, height: GLsizei; format, type_: GLenum; pixels: PGLvoid); cdecl; external LibGLES;
procedure glRotatex(angle, x, y, z: GLfixed); cdecl; external LibGLES;
procedure glSampleCoverage(value: GLclampf; invert: GLboolean); cdecl; external LibGLES;
procedure glSampleCoveragex(value: GLclampx; invert: GLboolean); cdecl; external LibGLES;
procedure glScalex(x, y, z: GLfixed); cdecl; external LibGLES;
procedure glScissor(x, y: GLint; width, height: GLsizei); cdecl; external LibGLES;
procedure glShadeModel(mode: GLenum); cdecl; external LibGLES;
procedure glStencilFunc(func: GLenum; ref: GLint; mask: GLuint); cdecl; external LibGLES;
procedure glStencilMask(mask: GLuint); cdecl; external LibGLES;
procedure glStencilOp(fail, zfail, zpass: GLenum); cdecl; external LibGLES;
procedure glTexCoordPointer(size: GLint; type_: GLenum; stride: GLsizei; pointer: PGLvoid); cdecl; external LibGLES;
procedure glTexEnvi(target, pname: GLenum; param: GLint); cdecl; external LibGLES;
procedure glTexEnvx(target, pname: GLenum; param: GLfixed); cdecl; external LibGLES;
procedure glTexEnviv(target, pname: GLenum; params: PGLint); cdecl; external LibGLES;
procedure glTexEnvxv(target, pname: GLenum; params: PGLfixed); cdecl; external LibGLES;
procedure glTexImage2D(target: GLenum; level, internalformat: GLint; width, height: GLsizei; border: GLint; format, type_: GLenum; pixels: PGLvoid); cdecl; external LibGLES;
procedure glTexParameteri(target, pname: GLenum; param: GLint); cdecl; external LibGLES;
procedure glTexParameterx(target, pname: GLenum; param: GLfixed); cdecl; external LibGLES;
procedure glTexParameteriv(target, pname: GLenum; params: PGLint); cdecl; external LibGLES;
procedure glTexParameterxv(target, pname: GLenum; params: PGLfixed); cdecl; external LibGLES;
procedure glTexSubImage2D(target: GLenum; level, xoffset, yoffset: GLint; width, height: GLsizei; format, type_: GLenum; pixels: PGLvoid); cdecl; external LibGLES;
procedure glTranslatex(x, y, z: GLfixed); cdecl; external LibGLES;
procedure glVertexPointer(size: GLint; type_: GLenum; stride: GLsizei; pointer: PGLvoid); cdecl; external LibGLES;
procedure glViewport(x, y: GLint; width, height: GLsizei); cdecl; external LibGLES;

procedure glPointSizePointerOES(type_: GLenum; stride: GLsizei; pointer: PGLvoid); cdecl; external LibGLES;

var
  glBlendFuncSeparate: procedure(sfactorRGB: TGLenum; dfactorRGB: TGLenum; sfactorAlpha: TGLenum; dfactorAlpha: TGLenum); cdecl;
  glIsRenderbuffer: function(renderbuffer: GLuint): GLboolean; cdecl;
  glBindRenderbuffer: procedure(target: GLenum; renderbuffer: GLuint);  cdecl;
  glDeleteRenderbuffers: procedure(n: GLsizei; const renderbuffers: PGLuint);  cdecl;
  glGenRenderbuffers: procedure(n: GLsizei; renderbuffers: PGLuint);  cdecl;
  glRenderbufferStorage: procedure(target: GLenum; internalformat: GLenum; width: GLsizei; height: GLsizei);  cdecl;
  glIsFramebuffer: function(framebuffer: GLuint): GLboolean;  cdecl;
  glBindFramebuffer: procedure(target: GLenum; framebuffer: GLuint);  cdecl;
  glDeleteFramebuffers: procedure(n: GLsizei; const framebuffers: PGLuint);  cdecl;
  glGenFramebuffers: procedure(n: GLsizei; framebuffers: PGLuint);  cdecl;
  glCheckFramebufferStatus: function(target: GLenum): GLenum;  cdecl;
  glFramebufferTexture2D: procedure(target: GLenum; attachment: GLenum; textarget: GLenum; texture: GLuint; level: GLint);  cdecl;
  glFramebufferRenderbuffer: procedure(target: GLenum; attachment: GLenum; renderbuffertarget: GLenum; renderbuffer: GLuint);  cdecl;

procedure InitOpenGLES;
procedure UnInitOpenGLES;

implementation

var LibOpenGLES: TG2DynLib;

function glProc(const Name: AnsiString; const DefProc: Pointer = nil): Pointer;
begin
  Result := G2DynLibAddress(LibOpenGLES, Name);
  if Result = nil then Result := G2DynLibAddress(LibOpenGLES, Name + 'OES');
  if Result = nil then Result := DefProc;
end;

procedure InitOpenGLES;
begin
  if LibOpenGLES <> 0 then UnInitOpenGLES;
  LibOpenGLES := G2DynLibOpen(LibGLES);
  Pointer(glBlendFuncSeparate) := glProc('glBlendFuncSeparate');
  Pointer(glIsRenderbuffer) := glProc('glIsRenderbuffer');
  Pointer(glBindRenderbuffer) := glProc('glBindRenderbuffer');
  Pointer(glDeleteRenderbuffers) := glProc('glDeleteRenderbuffers');
  Pointer(glGenRenderbuffers) := glProc('glGenRenderbuffers');
  Pointer(glRenderbufferStorage) := glProc('glRenderbufferStorage');
  Pointer(glIsFramebuffer) := glProc('glIsFramebuffer');
  Pointer(glBindFramebuffer) := glProc('glBindFramebuffer');
  Pointer(glDeleteFramebuffers) := glProc('glDeleteFramebuffers');
  Pointer(glGenFramebuffers) := glProc('glGenFramebuffers');
  Pointer(glCheckFramebufferStatus) := glProc('glCheckFramebufferStatus');
  Pointer(glFramebufferTexture2D) := glProc('glFramebufferTexture2D');
  Pointer(glFramebufferRenderbuffer) := glProc('glFramebufferRenderbuffer');
end;

procedure UnInitOpenGLES;
begin
  if LibOpenGLES <> 0 then
  G2DynLibClose(LibOpenGLES);
end;

end.

