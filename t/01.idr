module Raylib

CFFI : String -> String
CFFI fname = "C:" ++ fname ++ ",libraylib"


interface WrapIO a b | a where
   wrapIO : a -> b

Cast rb ra => WrapIO a b => WrapIO (ra -> a) (rb -> b) where
   wrapIO f x = wrapIO (f (cast x))

Cast a b => HasIO io => WrapIO (PrimIO a) (io b) where
   wrapIO p = do
      va <- primIO p
      pure (cast va)


Cast Bits8 Bool where
   cast 0 = True
   cast _ = False

Cast Bool Bits8 where
   cast True = 1
   cast False = 0


%foreign CFFI "InitWindow"
prim__InitWindow : Int -> Int -> String -> PrimIO ()

%foreign CFFI "WindowShouldClose"
prim__WindowShouldClose : PrimIO Bits8

%foreign CFFI "BeginDrawing"
prim__BeginDrawing : PrimIO ()

%foreign CFFI "EndDrawing"
prim__EndDrawing : PrimIO ()


public export
data Raylib : Type -> Type where
  InitWindow : Int -> Int -> String -> Raylib ()
  WindowShouldClose : Raylib Bool
  BeginDrawing : Raylib ()
  EndDrawing : Raylib ()


export
handleWithIO : HasIO io => Raylib a -> io a
handleWithIO (InitWindow a0 a1 a2) = (wrapIO prim__InitWindow) a0 a1 a2
handleWithIO (WindowShouldClose) = (wrapIO prim__WindowShouldClose)
handleWithIO (BeginDrawing) = (wrapIO prim__BeginDrawing)
handleWithIO (EndDrawing) = (wrapIO prim__EndDrawing)
