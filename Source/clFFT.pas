unit ClFft;

interface

uses
  CL, CL_GL, CL_Platform;

const
  CLibClFft = 'clfft.dll';

  CClFftVersionMajor = 2;
  CClFftVersionMinor = 2;
  CClFftVersionPatch = 0;

type
  TClFftStatus = (
    fsInvalidGlobalWorkSize = CL_INVALID_GLOBAL_WORK_SIZE,
    fsInvalidMipLevel = CL_INVALID_MIP_LEVEL,
    fsInvalidBufferSize = CL_INVALID_BUFFER_SIZE,
    fsInvalidGLObject = CL_INVALID_GL_OBJECT,
    fsInvalidOperation = CL_INVALID_OPERATION,
    fsInvalidEvent = CL_INVALID_EVENT,
    fsInvalidEventWaitList = CL_INVALID_EVENT_WAIT_LIST,
    fsInvalidGlobalOffset = CL_INVALID_GLOBAL_OFFSET,
    fsInvalidWorkItemSize = CL_INVALID_WORK_ITEM_SIZE,
    fsInvalidWorkGroupSize = CL_INVALID_WORK_GROUP_SIZE,
    fsInvalidWorkDimension = CL_INVALID_WORK_DIMENSION,
    fsInvalidKernelArgs = CL_INVALID_KERNEL_ARGS,
    fsInvalidArgSize = CL_INVALID_ARG_SIZE,
    fsInvalidArgValue = CL_INVALID_ARG_VALUE,
    fsInvalidArgIndex = CL_INVALID_ARG_INDEX,
    fsInvalidKernel = CL_INVALID_KERNEL,
    fsInvalidKernelDefinition = CL_INVALID_KERNEL_DEFINITION,
    fsInvalidKernelName = CL_INVALID_KERNEL_NAME,
    fsInvalidProgramExecutable = CL_INVALID_PROGRAM_EXECUTABLE,
    fsInvalidProgram = CL_INVALID_PROGRAM,
    fsInvalidBuildOptions = CL_INVALID_BUILD_OPTIONS,
    fsInvalidBinary = CL_INVALID_BINARY,
    fsInvalidSampler = CL_INVALID_SAMPLER,
    fsInvalidImageSize = CL_INVALID_IMAGE_SIZE,
    fsInvalidImageFormatDescriptor = CL_INVALID_IMAGE_FORMAT_DESCRIPTOR,
    fsInvalidMemObject = CL_INVALID_MEM_OBJECT,
    fsInvalidHostPtr = CL_INVALID_HOST_PTR,
    fsInvalidCommandQueue = CL_INVALID_COMMAND_QUEUE,
    fsInvalidQueueProperties = CL_INVALID_QUEUE_PROPERTIES,
    fsInvalidContext = CL_INVALID_CONTEXT,
    fsInvalidDevice = CL_INVALID_DEVICE,
    fsInvalidPlatform = CL_INVALID_PLATFORM,
    fsInvalidDeviceType = CL_INVALID_DEVICE_TYPE,
    fsInvalidValue = CL_INVALID_VALUE,
    fsMapFailure = CL_MAP_FAILURE,
    fsBuildProgramFailure = CL_BUILD_PROGRAM_FAILURE,
    fsImageFormatNotSupported = CL_IMAGE_FORMAT_NOT_SUPPORTED,
    fsImageFormatMismatch = CL_IMAGE_FORMAT_MISMATCH,
    fsMemCopyOverlap = CL_MEM_COPY_OVERLAP,
    fsProfilingInfoNotAvailable = CL_PROFILING_INFO_NOT_AVAILABLE,
    fsOutOfHostMemory = CL_OUT_OF_HOST_MEMORY,
    fsOutOfResources = CL_OUT_OF_RESOURCES,
    fsMemObjectAllocationFailure = CL_MEM_OBJECT_ALLOCATION_FAILURE,
    fsCompilerNotAvailable = CL_COMPILER_NOT_AVAILABLE,
    fsDeviceNotAvailable = CL_DEVICE_NOT_AVAILABLE,
    fsDeviceNotFound = CL_DEVICE_NOT_FOUND,
    fsSuccess = CL_SUCCESS,
    //-------------------------- Extended status codes for ClFft ----------------------------------------
    fsBugcheck = 4 * 1024,      // Bugcheck
    fsNotImplemented,           // Functionality is not implemented yet
    fsTransposedNotImplemented, // Transposed functionality is not implemented for this transformation
    fsFileNotFound,             // Tried to open an existing file on the host system, but failed
    fsFileCreateFailure,        // Tried to create a file on the host system, but failed
    fsVersionMismatch,          // Version conflict between client and library
    fsInvalidPlan,              // Requested plan could not be found
    fsDeviceNoDouble,           // Double precision not supported on this device
    fsDeviceMismatch            // Attempt to run on a device using a plan baked for a different device
  );

  TClFftDim = (
    fd1D = 1,  // 1 Dimensional FFT transform (default)
    fd2D,      // 2 Dimensional FFT transform.
    fd3D       // 3 Dimensional FFT transform.
  );

  TClFftLayout = (
    flComplexInterleaved = 1, // An array of complex numbers, with real and imaginary components together (default)
    flComplexPlanar,          // Arrays of real componets and arrays of imaginary components that have been seperated out
    flHermitianInterleaved,   // Compressed form of complex numbers; complex-conjugates not stored, real and imaginary components in same array
    flHermitianPlanar,        // Compressed form of complex numbers; complex-conjugates not stored, real and imaginary components in separate arrays
    flReal                    // An array of real numbers, with no corresponding imaginary components
  );

  TClFftPrecision = (
    fpSingle = 1, // An array of complex numbers, with real and imaginary components as floats (default)
    fpDouble,     // An array of complex numbers, with real and imaginary components as doubles
    fpSingleFast, // Faster implementation preferred
    fpDoubleFast  // Faster implementation preferred
  );

  TClFftDirection = (
    fdForward = -1, // FFT transform from the time to the frequency domain.
    fdBackward = 1  // FFT transform from the frequency to the time domain.
  );

  TClFftResultLocation =
  (
    frlInplace    = 1, // The input and output buffers are the same (default)
    frlOutofplace      // Seperate input and output buffers
  );

  TClFftResultTransposed = (
    frtNoTranspose = 1, // The results are returned in the original preserved order (default)
    frtTransposed       // The result is transposed where transpose kernel is supported (possibly faster)
  );

const
  ClFftDumpPrograms = 1;

type
  TClFftSetupData = record
    Major: TCL_uint;    // Major version number of the project; signifies major API changes
    Minor: TCL_uint;    // Minor version number of the project; minor API changes that could break backwards compatibility
    Patch: TCL_uint;    // Patch version number of the project; Always incrementing number, signifies change over time
    DebugFlags: TCL_ulong;  // This should be set to zero, except when debugging the ClFft library.
  end;
  PClFftSetupData = ^TClFftSetupData;

  TClFftPlanHandle = NativeUInt;

  TNotification = procedure (plHandle: TClFftPlanHandle; UserData: Pointer);

function ClFftInitSetupData(var SetupData: TClFftSetupData): TClFftStatus;

function ClFftSetup(var SetupData: TClFftSetupData): TClFftStatus; cdecl; external CLibClFft name 'clfftSetup';
function ClFftTeardown: TClFftStatus; cdecl; external CLibClFft name 'clfftTeardown';
function ClFftGetVersion(var Major, Minor, Patch: TCL_uint): TClFftStatus; cdecl; external CLibClFft name 'clfftGetVersion';
function ClFftCreateDefaultPlan(out PlanHandle: TClFftPlanHandle;
  Context: TCL_Context; const dim: TClFftDim; var clLengths: NativeUInt): TClFftStatus; cdecl; external CLibClFft name 'clfftCreateDefaultPlan';
function ClFftCopyPlan(out OutPlanHandle: TClFftPlanHandle; NewContext: TCL_Context;
  InPlanHandle: TClFftPlanHandle): TClFftStatus; cdecl; external CLibClFft name 'clfftCopyPlan';
function ClFftBakePlan(plHandle: TClFftPlanHandle;
  NumQueues: TCL_uint; commQueueFFT: Pcl_command_queue; Notification: TNotification; UserData: Pointer): TClFftStatus; cdecl; external CLibClFft name 'clfftBakePlan';
function ClFftDestroyPlan(var plHandle: TClFftPlanHandle): TClFftStatus; cdecl; external CLibClFft name 'clfftDestroyPlan';
function ClFftGetPlanContext(const plHandle: TClFftPlanHandle;
  Context: Pcl_context): TClFftStatus; cdecl; external CLibClFft name 'clfftGetPlanContext';
function ClFftGetPlanPrecision(const plHandle: TClFftPlanHandle;
  out Precision: TClFftPrecision): TClFftStatus; cdecl; external CLibClFft name 'clfftGetPlanPrecision';
function ClFftSetPlanPrecision(plHandle: TClFftPlanHandle;
  Precision: TClFftPrecision): TClFftStatus; cdecl; external CLibClFft name 'clfftSetPlanPrecision';
function ClFftGetPlanScale(const plHandle: TClFftPlanHandle;
  Dir: TClFftDirection; out Scale: TCL_float): TClFftStatus; cdecl; external CLibClFft name 'clfftGetPlanScale';
function ClFftSetPlanScale(plHandle: TClFftPlanHandle;
  Dir: TClFftDirection; Scale: TCL_float): TClFftStatus; cdecl; external CLibClFft name 'clfftSetPlanScale';
function ClFftGetPlanBatchSize(const plHandle: TClFftPlanHandle;
  out BatchSize: NativeUint): TClFftStatus; cdecl; external CLibClFft name 'clfftGetPlanBatchSize';
function ClFftSetPlanBatchSize(plHandle: TClFftPlanHandle;
  BatchSize: NativeUint): TClFftStatus; cdecl; external CLibClFft name 'clfftSetPlanBatchSize';
function ClFftGetPlanDim(const plHandle: TClFftPlanHandle;
  out dim: TClFftDim; out size: TCL_uint): TClFftStatus; cdecl; external CLibClFft name 'clfftGetPlanDim';
function ClFftSetPlanDim(plHandle: TClFftPlanHandle;
  const dim: TClFftDim): TClFftStatus; cdecl; external CLibClFft name 'clfftSetPlanDim';
function ClFftGetPlanLength(const plHandle: TClFftPlanHandle;
  const dim: TClFftDim; out clLengths: NativeUInt): TClFftStatus; cdecl; external CLibClFft name 'clfftGetPlanLength';
function ClFftSetPlanLength(plHandle: TClFftPlanHandle;
  const dim: TClFftDim; var clLengths: NativeUInt): TClFftStatus; cdecl; external CLibClFft name 'clfftSetPlanLength';
function ClFftGetPlanInStride(const plHandle: TClFftPlanHandle;
  const dim: TClFftDim; out clStrides: NativeUInt): TClFftStatus; cdecl; external CLibClFft name 'clfftGetPlanInStride';
function ClFftSetPlanInStride(plHandle: TClFftPlanHandle;
  const dim: TClFftDim; var clStrides: NativeUInt): TClFftStatus; cdecl; external CLibClFft name 'clfftSetPlanInStride';
function ClFftGetPlanOutStride(const plHandle: TClFftPlanHandle;
  const dim: TClFftDim; var clStrides: NativeUInt): TClFftStatus; cdecl; external CLibClFft name 'clfftGetPlanOutStride';
function ClFftSetPlanOutStride(plHandle: TClFftPlanHandle;
  const dim: TClFftDim; var clStrides: NativeUInt): TClFftStatus; cdecl; external CLibClFft name 'clfftSetPlanOutStride';
function ClFftGetPlanDistance(const plHandle: TClFftPlanHandle;
  var iDist, oDist: NativeUInt): TClFftStatus; cdecl; external CLibClFft name 'clfftGetPlanDistance';
function ClFftSetPlanDistance(plHandle: TClFftPlanHandle;
  iDist, oDist: NativeUInt): TClFftStatus; cdecl; external CLibClFft name 'clfftSetPlanDistance';
function ClFftGetLayout(const plHandle: TClFftPlanHandle;
  out iLayout, oLayout: TClFftLayout): TClFftStatus; cdecl; external CLibClFft name 'clfftGetLayout';
function ClFftSetLayout(plHandle: TClFftPlanHandle;
  iLayout, oLayout: TClFftLayout ): TClFftStatus; cdecl; external CLibClFft name 'clfftSetLayout';
function ClFftGetResultLocation(const plHandle: TClFftPlanHandle;
  out Placeness: TClFftResultLocation): TClFftStatus; cdecl; external CLibClFft name 'clfftGetResultLocation';
function ClFftSetResultLocation(plHandle: TClFftPlanHandle;
  Placeness: TClFftResultLocation): TClFftStatus; cdecl; external CLibClFft name 'clfftSetResultLocation';
function ClFftGetPlanTransposeResult(const plHandle: TClFftPlanHandle;
  out Transposed: TClFftResultTransposed): TClFftStatus; cdecl; external CLibClFft name 'clfftGetPlanTransposeResult';
function ClFftSetPlanTransposeResult(plHandle: TClFftPlanHandle;
  Transposed: TClFftResultTransposed): TClFftStatus; cdecl; external CLibClFft name 'clfftSetPlanTransposeResult';
function ClFftGetTmpBufSize(const plHandle: TClFftPlanHandle;
  out BufferSize: NativeUInt): TClFftStatus; cdecl; external CLibClFft name 'clfftGetTmpBufSize';
function ClFftEnqueueTransform(plHandle: TClFftPlanHandle; dir: TClFftDirection;
  numQueuesAndEvents: TCL_uint; commQueues: PCL_command_queue; numWaitEvents: TCL_uint;
  var waitEvents, outEvents: TCL_event; var inputBuffers, outputBuffers: TCL_mem; tmpBuffer: TCL_mem): TClFftStatus; cdecl; external CLibClFft name 'clfftEnqueueTransform';

implementation

function ClFftInitSetupData(var SetupData: TClFftSetupData): TClFftStatus;
begin
  SetupData.Major := CClFftVersionMajor;
  SetupData.Minor := CClFftVersionMinor;
  SetupData.Patch := CClFftVersionPatch;
  SetupData.DebugFlags := 0;

  Result := fsSuccess;
end;

end.
