local M = {}

-------------------------------------------------------------------------------
-- Export QGL::FormatOption enum
-------------------------------------------------------------------------------
M.FormatOption = {}
M.FormatOption.DoubleBuffer				= 1				
M.FormatOption.DepthBuffer				= 2				
M.FormatOption.Rgba						= 4				
M.FormatOption.AlphaChannel				= 8				
M.FormatOption.AccumBuffer				= 16				
M.FormatOption.StencilBuffer			= 32				
M.FormatOption.StereoBuffers			= 64				
M.FormatOption.DirectRendering			= 128				
M.FormatOption.HasOverlay				= 256	
M.FormatOption.SampleBuffers			= 512
M.FormatOption.DeprecatedFunctions		= 1024			
M.FormatOption.SingleBuffer				= 65536
M.FormatOption.NoDepthBuffer			= 131072
M.FormatOption.ColorIndex				= 262144
M.FormatOption.NoAlphaChannel			= 524288
M.FormatOption.NoAccumBuffer			= 1048576
M.FormatOption.NoStencilBuffer			= 2097152
M.FormatOption.NoStereoBuffers			= 4194304
M.FormatOption.IndirectRendering		= 8388608
M.FormatOption.NoOverlay				= 16777216
M.FormatOption.NoSampleBuffers			= 33554432
M.FormatOption.NoDeprecatedFunctions	= 67108864

-------------------------------------------------------------------------------
-- Export Qt:CheckState enum
-------------------------------------------------------------------------------
M.Unchecked	= 0
M.PartiallyChecked = 1
M.Checked = 2

-------------------------------------------------------------------------------
-- Export Qt::MouseButton enum
-------------------------------------------------------------------------------
M.NoButton		= 0x00000000
M.LeftButton	= 0x00000001
M.RightButton	= 0x00000002
M.MidButton		= 0x00000004
M.MiddleButton	= M.MidButton

-------------------------------------------------------------------------------
-- Export Qt::FocusPolicy enum
-------------------------------------------------------------------------------
M.TabFocus 					= 0x1
M.ClickFocus				= 0x2
M.StrongFocus				= M.TabFocus + M.ClickFocus + 0x8
M.WheelFocus				= M.StrongFocus + 0x4
M.NoFocus					= 0

-------------------------------------------------------------------------------
-- Export Qt::ItemFlag enum (see AbstractItemModelDelegate:getData())
-------------------------------------------------------------------------------
M.NoItemFlags				= 0
M.ItemIsSelectable			= 1
M.ItemIsEditable			= 2
M.ItemIsDragEnabled			= 4
M.ItemIsDropEnabled			= 8
M.ItemIsUserCheckable		= 16
M.ItemIsEnabled				= 32
M.ItemIsTristate			= 64

-------------------------------------------------------------------------------
-- Export Qt::BrushStyle enum
-------------------------------------------------------------------------------
M.NoBrush 					= 0
M.SolidPattern 				= 1
M.Dense1Pattern				= 2
M.Dense2Pattern				= 3
M.Dense3Pattern				= 4
M.Dense4Pattern				= 5
M.Dense5Pattern				= 6
M.Dense6Pattern				= 7
M.Dense7Pattern				= 8
M.HorPattern				= 9
M.VerPattern				= 10
M.CrossPattern				= 11
M.BDiagPattern				= 12
M.FDiagPattern				= 13
M.DiagCrossPattern			= 14
M.LinearGradientPattern		= 15
M.ConicalGradientPattern	= 17
M.RadialGradientPattern		= 16
M.TexturePattern			= 24

-------------------------------------------------------------------------------
-- Export Qt::CusrorShape enum
-------------------------------------------------------------------------------
M.ArrowCursor				= 0
M.UpArrowCursor				= 1
M.CrossCursor				= 2
M.WaitCursor				= 3
M.IBeamCursor				= 4
M.SizeVerCursor				= 5
M.SizeHorCursor				= 6
M.SizeBDiagCursor			= 7
M.SizeFDiagCursor			= 8
M.SizeAllCursor				= 9
M.BlankCursor				= 10
M.SplitVCursor				= 11
M.SplitHCursor				= 12
M.PointingHandCursor		= 13
M.ForbiddenCursor			= 14
M.OpenHandCursor			= 17
M.ClosedHandCursor			= 18
M.WhatsThisCursor			= 15
M.BusyCursor				= 16
M.DragMoveCursor			= 20
M.DragCopyCursor			= 19
M.DragLinkCursor			= 21
M.BitmapCursor				= 24

-------------------------------------------------------------------------------
-- Export Qt::AlignmentFlag enum
-------------------------------------------------------------------------------
M.AlignLeft					= 0x0001
M.AlignRight				= 0x0002
M.AlignHCenter				= 0x0004
M.AlignJustify				= 0x0008
M.AlignTop					= 0x0020
M.AlignBottom				= 0x0040
M.AlignVCenter				= 0x0080
M.AlignAbsolute				= 0x0010
M.AlignCenter				= M.AlignHCenter + M.AlignVCenter
M.Horizontal 				= 0x1
M.Vertical 					= 0x2

-------------------------------------------------------------------------------
-- Export Qt::Corner enum
-------------------------------------------------------------------------------
M.TopLeftCorner			= 0x00000
M.TopRightCorner		= 0x00001
M.BottomLeftCorner		= 0x00002
M.BottomRightCorner		= 0x0

-------------------------------------------------------------------------------
-- Export Qt::DockWidgetArea enum
-------------------------------------------------------------------------------
M.LeftDockWidgetArea		= 0x1
M.RightDockWidgetArea		= 0x2
M.TopDockWidgetArea			= 0x4
M.BottomDockWidgetArea		= 0x8
M.AllDockWidgetAreas		= 0xf
M.NoDockWidgetArea			= 0

-------------------------------------------------------------------------------
-- Export QMessageBox enums
-------------------------------------------------------------------------------
M.MessageBox = {}

M.MessageBox.NoIcon				= 0
M.MessageBox.Question			= 4
M.MessageBox.Information		= 1
M.MessageBox.Warning			= 2
M.MessageBox.Critical			= 3
M.MessageBox.Ok					= 0x00000400
M.MessageBox.Open				= 0x00002000
M.MessageBox.Save				= 0x00000800
M.MessageBox.Cancel				= 0x00400000
M.MessageBox.Close				= 0x00200000
M.MessageBox.Discard			= 0x00800000
M.MessageBox.Apply				= 0x02000000
M.MessageBox.Reset				= 0x04000000
M.MessageBox.RestoreDefaults	= 0x08000000
M.MessageBox.Help				= 0x01000000
M.MessageBox.SaveAll			= 0x00001000
M.MessageBox.Yes				= 0x00004000
M.MessageBox.YesToAll			= 0x00008000
M.MessageBox.No					= 0x00010000
M.MessageBox.NoToAll			= 0x00020000
M.MessageBox.Abort				= 0x00040000
M.MessageBox.Retry				= 0x00080000
M.MessageBox.Ignore				= 0x00100000
M.MessageBox.NoButton			= 0x00000000

M.NoContextMenu			= 0
M.PreventContextMenu 	= 4
M.DefaultContextMenu 	= 1
M.ActionsContextMenu 	= 2
M.CustomContextMenu 	= 3	

-------------------------------------------------------------------------------
-- Lua constructors for supported Qt types
-------------------------------------------------------------------------------
-- Constructs a qt icon instance using qt.Variant
function M.Icon( filename )
	local variant = co.new( "qt.Variant" )
	variant:setIcon( filename )
	return variant
end

-- Constructs a qt point instance using qt.Variant
function M.Point( x, y )
	local variant = co.new( "qt.Variant" )
	variant:setPoint( x, y )
	return variant
end

-- Constructs a qt color instance using qt.Variant
function M.Color( r, g, b, a )
	local variant = co.new( "qt.Variant" )
	variant:setColor( r, g, b, a or 255 )
	return variant
end

-- Constructs a qt brush instance using qt.Variant
function M.Brush( r, g, b, a, style )
	local variant = co.new( "qt.Variant" )
	variant:setBrush( r, g, b, a or 1, style or M.SolidPattern )
	return variant
end

-- Constructs a qt size instance using qt.Variant
function M.Size( width, height )
	local variant = co.new( "qt.Variant" )
	variant:setSize( width or -1, height or -1 )
	return variant
end

-- Constructs a qt font instance using qt.Variant
function M.Font( family, pointSize, weight, italic )
	local variant = co.new( "qt.Variant" )
	variant:setFont( family, pointSize or -1, weight or -1, italic or false )
	return variant
end

-------------------------------------------------------------------------------
-- Constructor for qt.Menu using qt.newInstanceOf() of ISystem
-------------------------------------------------------------------------------
function M.Menu( title )
	local menu = M.parent.new( "QMenu" )
	menu.title = title or ""
	return menu
end

return M

