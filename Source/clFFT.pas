unit ClFft;

interface

uses
  OpenCL;

const
  CLibClFft = 'clFFT.dll';

  CClFftVersionMajor = 2;
  CClFftVersionMinor = 2;
  CClFftVersionPatch = 0;

type
  TClFftStatus = (
    ClFftInvalidGlobalWorkSize = CL_INVALID_GLOBAL_WORK_SIZE,
    ClFftInvalidMipLevel = CL_INVALID_MIP_LEVEL,
    ClFftInvalidBufferSize = CL_INVALID_BUFFER_SIZE,
    ClFftInvalidGLObject = CL_INVALID_GL_OBJECT,
    ClFftInvalidOperation = CL_INVALID_OPERATION,
    ClFftInvalidEvent = CL_INVALID_EVENT,
    ClFftInvalidEventWaitList = CL_INVALID_EVENT_WAIT_LIST,
    ClFftInvalidGlobalOffset = CL_INVALID_GLOBAL_OFFSET,
    ClFftInvalidWorkItemSize = CL_INVALID_WORK_ITEM_SIZE,
    ClFftInvalidWorkGroupSize = CL_INVALID_WORK_GROUP_SIZE,
    ClFftInvalidWorkDimension = CL_INVALID_WORK_DIMENSION,
    ClFftInvalidKernelArgs = CL_INVALID_KERNEL_ARGS,
    ClFftInvalidArgSize = CL_INVALID_ARG_SIZE,
    ClFftInvalidArgValue = CL_INVALID_ARG_VALUE,
    ClFftInvalidArgIndex = CL_INVALID_ARG_INDEX,
    ClFftInvalidKernel = CL_INVALID_KERNEL,
    ClFftInvalidKernelDefinition = CL_INVALID_KERNEL_DEFINITION,
    ClFftInvalidKernelName = CL_INVALID_KERNEL_NAME,
    ClFftInvalidProgramExecutable = CL_INVALID_PROGRAM_EXECUTABLE,
    ClFftInvalidProgram = CL_INVALID_PROGRAM,
    ClFftInvalidBuildOptions = CL_INVALID_BUILD_OPTIONS,
    ClFftInvalidBinary = CL_INVALID_BINARY,
    ClFftInvalidSampler = CL_INVALID_SAMPLER,
    ClFftInvalidImageSize = CL_INVALID_IMAGE_SIZE,
    ClFftInvalidImageFormatDescriptor = CL_INVALID_IMAGE_FORMAT_DESCRIPTOR,
    ClFftInvalidMemObject = CL_INVALID_MEM_OBJECT,
    ClFftInvalidHostPtr = CL_INVALID_HOST_PTR,
    ClFftInvalidCommandQueue = CL_INVALID_COMMAND_QUEUE,
    ClFftInvalidQueueProperties = CL_INVALID_QUEUE_PROPERTIES,
    ClFftInvalidContext = CL_INVALID_CONTEXT,
    ClFftInvalidDevice = CL_INVALID_DEVICE,
    ClFftInvalidPlatform = CL_INVALID_PLATFORM,
    ClFftInvalidDeviceType = CL_INVALID_DEVICE_TYPE,
    ClFftInvalidValue = CL_INVALID_VALUE,
    ClFftMapFailure = CL_MAP_FAILURE,
    ClFftBuildProgramFailure = CL_BUILD_PROGRAM_FAILURE,
    ClFftImageFormatNotSupported = CL_IMAGE_FORMAT_NOT_SUPPORTED,
    ClFftImageFormatMismatch = CL_IMAGE_FORMAT_MISMATCH,
    ClFftMemCopyOverlap = CL_MEM_COPY_OVERLAP,
    ClFftProfilingInfoNotAvailable = CL_PROFILING_INFO_NOT_AVAILABLE,
    ClFftOutOfHostMemory = CL_OUT_OF_HOST_MEMORY,
    ClFftOutOfResources = CL_OUT_OF_RESOURCES,
    ClFftMemObjectAllocationFailure = CL_MEM_OBJECT_ALLOCATION_FAILURE,
    ClFftCompilerNotAvailable = CL_COMPILER_NOT_AVAILABLE,
    ClFftDeviceNotAvailable = CL_DEVICE_NOT_AVAILABLE,
    ClFftDeviceNotFound = CL_DEVICE_NOT_FOUND,
    ClFftSuccess = CL_SUCCESS,
    //-------------------------- Extended status codes for ClFft ----------------------------------------
    ClFftBugcheck = 4 * 1024,  // Bugcheck
    ClFftNotImplemented,    // Functionality is not implemented yet
    ClFftTransposedNotImplemented, // Transposed functionality is not implemented for this transformation
    ClFftFileNotFound,    // Tried to open an existing file on the host system, but failed
    ClFftFileCreateFailure,  // Tried to create a file on the host system, but failed
    ClFftVersionMismatch,    // Version conflict between client and library
    ClFftInvalidPlan,      // Requested plan could not be found
    ClFftDeviceNoDouble,    // Double precision not supported on this device
    ClFftDeviceMismatch,    // Attempt to run on a device using a plan baked for a different device
  );

  TClFftDim = (
    ClFft1D = 1,  // 1 Dimensional FFT transform (default)
    ClFft2D,      // 2 Dimensional FFT transform.
    ClFft3D       // 3 Dimensional FFT transform.
  );

  TClFftLayout = (
    ClFftComplexInterleaved = 1, // An array of complex numbers, with real and imaginary components together (default)
    ClFftComplexPlanar,          // Arrays of real componets and arrays of imaginary components that have been seperated out
    ClFftHermitianInterleaved,   // Compressed form of complex numbers; complex-conjugates not stored, real and imaginary components in same array
    ClFftHermitianPlanar,        // Compressed form of complex numbers; complex-conjugates not stored, real and imaginary components in separate arrays
    ClFftReal                    // An array of real numbers, with no corresponding imaginary components
  );

  TClFftPrecision = (
    ClFftSingle = 1, // An array of complex numbers, with real and imaginary components as floats (default)
    ClFftDouble,     // An array of complex numbers, with real and imaginary components as doubles
    ClFftSingleFast, // Faster implementation preferred
    ClFftDoubleFast  // Faster implementation preferred
  );

  TClFftDirection = (
    ClFftForward = -1, // FFT transform from the time to the frequency domain.
    ClFftBackward = 1  // FFT transform from the frequency to the time domain.
  );

  TClFftResultLocation =
  (
    ClFftInplace    = 1, // The input and output buffers are the same (default)
    ClFftOutofplace,     // Seperate input and output buffers
  );

  TClFftResultTransposed = (
    ClFftNoTranspose = 1, // The results are returned in the original preserved order (default)
    ClFftTransposed,      // The result is transposed where transpose kernel is supported (possibly faster)
  );

const
  ClFftDumpPrograms = 1;

type
  TClFftSetupData = record
    Major: cl_uint;    // Major version number of the project; signifies major API changes
    Minor: cl_uint;    // Minor version number of the project; minor API changes that could break backwards compatibility
    Patch: cl_uint;    // Patch version number of the project; Always incrementing number, signifies change over time
    DebugFlags: cl_ulong;  // This should be set to zero, except when debugging the ClFft library.
  end;
  PClFftSetupData = ^TClFftSetupData;

  TClFftPlanHandle = NativeUInt;

  TNotification = function (plHandle: TClFftPlanHandle; UserData: Pointer): CL_CALLBACK;

function ClFftInitSetupData(var SetupData: TClFftSetupData): ClFftStatus;

function ClFftSetup(var SetupData TClFftSetupData): ClFftStatus; cdecl; external CLibClFft;
function ClFftTeardown: ClFftStatus; cdecl; external CLibClFft;
function ClFftGetVersion(var Major, Minor, Patch: cl_uint): ClFftStatus;
function ClFftCreateDefaultPlan(out PlanHandle: TClFftPlanHandle;
  Context: cl_context; const dim: ClFftDim; var clLengths: NativeUInt): ClFftStatus; cdecl; external CLibClFft;
function ClFftCopyPlan(out OutPlanHandle: ClFftPlanHandle; NewContext: cl_context;
  InPlanHandle: ClFftPlanHandle): ClFftStatus; cdecl; external CLibClFft;
function ClFftBakePlan(plHandle: TClFftPlanHandle;
  NumQueues: cl_uint; commQueueFFT: Pcl_command_queue; Notification: TNotification; UserData: Pointer): ClFftStatus; cdecl; external CLibClFft;
function ClFftDestroyPlan(var plHandle: TClFftPlanHandle): ClFftStatus; cdecl; external CLibClFft;
function ClFftGetPlanContext(const plHandle: TClFftPlanHandle;
  Context: Pcl_context): ClFftStatus; cdecl; external CLibClFft;
function ClFftGetPlanPrecision(const plHandle: TClFftPlanHandle;
  Precision: PClFftPrecision): ClFftStatus; cdecl; external CLibClFft;
function ClFftSetPlanPrecision(plHandle: TClFftPlanHandle;
  Precision: ClFftPrecision): ClFftStatus; cdecl; external CLibClFft;
function ClFftGetPlanScale(const plHandle: TClFftPlanHandle;
  Dir: ClFftDirection; out Scale: cl_float): ClFftStatus; cdecl; external CLibClFft;
function ClFftSetPlanScale(plHandle: TClFftPlanHandle;
  Dir: ClFftDirection; Scale: cl_float): ClFftStatus; cdecl; external CLibClFft;
function ClFftGetPlanBatchSize(const plHandle: TClFftPlanHandle;
  out BatchSize: NativeUint): ClFftStatus; cdecl; external CLibClFft;
function ClFftSetPlanBatchSize(plHandle: TClFftPlanHandle;
  BatchSize: NativeUint): ClFftStatus; cdecl; external CLibClFft;
function ClFftGetPlanDim(const plHandle: TClFftPlanHandle;
  out dim: ClFftDim; out size: cl_uint): ClFftStatus; cdecl; external CLibClFft;
function ClFftSetPlanDim(plHandle: TClFftPlanHandle;
  const dim: ClFftDim): ClFftStatus; cdecl; external CLibClFft;
function ClFftGetPlanLength(const plHandle: TClFftPlanHandle;
  const dim: ClFftDim; out clLengths: NativeUInt): ClFftStatus; cdecl; external CLibClFft;
function ClFftSetPlanLength(plHandle: TClFftPlanHandle;
  const dim: ClFftDim; var clLengths: NativeUInt): ClFftStatus; cdecl; external CLibClFft;
function ClFftGetPlanInStride(const plHandle: TClFftPlanHandle;
  const dim: ClFftDim; our clStrides: NativeUInt): ClFftStatus; cdecl; external CLibClFft;
function ClFftSetPlanInStride(plHandle: TClFftPlanHandle;
  const dim: ClFftDim; var clStrides: NativeUInt): ClFftStatus; cdecl; external CLibClFft;
function ClFftGetPlanOutStride(const plHandle: TClFftPlanHandle;
  const dim: ClFftDim; var clStrides: NativeUInt): ClFftStatus; cdecl; external CLibClFft;
function ClFftSetPlanOutStride(plHandle: TClFftPlanHandle;
  const dim: ClFftDim; var clStrides: NativeUInt): ClFftStatus; cdecl; external CLibClFft;
function ClFftGetPlanDistance(const plHandle: TClFftPlanHandle;
  var iDist, oDist: NativeUInt): ClFftStatus; cdecl; external CLibClFft;
function ClFftSetPlanDistance(plHandle: TClFftPlanHandle;
  iDist, oDist: NativeUInt): ClFftStatus; cdecl; external CLibClFft;
function ClFftGetLayout(const plHandle: TClFftPlanHandle;
  out iLayout, oLayout: ClFftLayout): ClFftStatus; cdecl; external CLibClFft;
function ClFftSetLayout(plHandle: TClFftPlanHandle;
  iLayout, oLayout: ClFftLayout ): ClFftStatus; cdecl; external CLibClFft;
function ClFftGetResultLocation(const plHandle: TClFftPlanHandle;
  out Placeness: ClFftResultLocation): ClFftStatus; cdecl; external CLibClFft;
function ClFftSetResultLocation(plHandle: TClFftPlanHandle;
  Placeness: ClFftResultLocation): ClFftStatus; cdecl; external CLibClFft;
function ClFftGetPlanTransposeResult(const plHandle: TClFftPlanHandle;
  out Transposed: ClFftResultTransposed): ClFftStatus; cdecl; external CLibClFft;
function ClFftSetPlanTransposeResult(plHandle: TClFftPlanHandle;
  Transposed: ClFftResultTransposed): ClFftStatus; cdecl; external CLibClFft;
function ClFftStatus ClFftGetTmpBufSize(const plHandle: TClFftPlanHandle;
  out BufferSize: NativeUInt): ClFftStatus; cdecl; external CLibClFft;
function ClFftEnqueueTransform(plHandle: TClFftPlanHandle; dir: ClFftDirection;
  numQueuesAndEvents: cl_uint; commQueues: cl_command_queue*; numWaitEvents: cl_uint;
  var waitEvents, outEvents: cl_event; var inputBuffers, outputBuffers: cl_mem; tmpBuffer: cl_mem); cdecl; external CLibClFft;

implementation

function ClFftInitSetupData(var SetupData: TClFftSetupData): ClFftStatus;
begin
  SetupData.Major := ClFftVersionMajor;
  SetupData.Minor := ClFftVersionMinor;
  SetupData.Patch := ClFftVersionPatch;
  SetupData.DebugFlags := 0;

  Result := ClFftSuccess;
end;

end.
