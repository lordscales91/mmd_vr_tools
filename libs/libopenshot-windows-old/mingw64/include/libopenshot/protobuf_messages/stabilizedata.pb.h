// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: stabilizedata.proto

#ifndef GOOGLE_PROTOBUF_INCLUDED_stabilizedata_2eproto
#define GOOGLE_PROTOBUF_INCLUDED_stabilizedata_2eproto

#include <limits>
#include <string>

#include <google/protobuf/port_def.inc>
#if PROTOBUF_VERSION < 3016000
#error This file was generated by a newer version of protoc which is
#error incompatible with your Protocol Buffer headers. Please update
#error your headers.
#endif
#if 3016000 < PROTOBUF_MIN_PROTOC_VERSION
#error This file was generated by an older version of protoc which is
#error incompatible with your Protocol Buffer headers. Please
#error regenerate this file with a newer version of protoc.
#endif

#include <google/protobuf/port_undef.inc>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/arena.h>
#include <google/protobuf/arenastring.h>
#include <google/protobuf/generated_message_table_driven.h>
#include <google/protobuf/generated_message_util.h>
#include <google/protobuf/metadata_lite.h>
#include <google/protobuf/generated_message_reflection.h>
#include <google/protobuf/message.h>
#include <google/protobuf/repeated_field.h>  // IWYU pragma: export
#include <google/protobuf/extension_set.h>  // IWYU pragma: export
#include <google/protobuf/unknown_field_set.h>
#include <google/protobuf/timestamp.pb.h>
// @@protoc_insertion_point(includes)
#include <google/protobuf/port_def.inc>
#define PROTOBUF_INTERNAL_EXPORT_stabilizedata_2eproto
PROTOBUF_NAMESPACE_OPEN
namespace internal {
class AnyMetadata;
}  // namespace internal
PROTOBUF_NAMESPACE_CLOSE

// Internal implementation detail -- do not use these members.
struct TableStruct_stabilizedata_2eproto {
  static const ::PROTOBUF_NAMESPACE_ID::internal::ParseTableField entries[]
    PROTOBUF_SECTION_VARIABLE(protodesc_cold);
  static const ::PROTOBUF_NAMESPACE_ID::internal::AuxiliaryParseTableField aux[]
    PROTOBUF_SECTION_VARIABLE(protodesc_cold);
  static const ::PROTOBUF_NAMESPACE_ID::internal::ParseTable schema[2]
    PROTOBUF_SECTION_VARIABLE(protodesc_cold);
  static const ::PROTOBUF_NAMESPACE_ID::internal::FieldMetadata field_metadata[];
  static const ::PROTOBUF_NAMESPACE_ID::internal::SerializationTable serialization_table[];
  static const ::PROTOBUF_NAMESPACE_ID::uint32 offsets[];
};
extern const ::PROTOBUF_NAMESPACE_ID::internal::DescriptorTable descriptor_table_stabilizedata_2eproto;
namespace pb_stabilize {
class Frame;
struct FrameDefaultTypeInternal;
extern FrameDefaultTypeInternal _Frame_default_instance_;
class Stabilization;
struct StabilizationDefaultTypeInternal;
extern StabilizationDefaultTypeInternal _Stabilization_default_instance_;
}  // namespace pb_stabilize
PROTOBUF_NAMESPACE_OPEN
template<> ::pb_stabilize::Frame* Arena::CreateMaybeMessage<::pb_stabilize::Frame>(Arena*);
template<> ::pb_stabilize::Stabilization* Arena::CreateMaybeMessage<::pb_stabilize::Stabilization>(Arena*);
PROTOBUF_NAMESPACE_CLOSE
namespace pb_stabilize {

// ===================================================================

class Frame PROTOBUF_FINAL :
    public ::PROTOBUF_NAMESPACE_ID::Message /* @@protoc_insertion_point(class_definition:pb_stabilize.Frame) */ {
 public:
  inline Frame() : Frame(nullptr) {}
  ~Frame() override;
  explicit constexpr Frame(::PROTOBUF_NAMESPACE_ID::internal::ConstantInitialized);

  Frame(const Frame& from);
  Frame(Frame&& from) noexcept
    : Frame() {
    *this = ::std::move(from);
  }

  inline Frame& operator=(const Frame& from) {
    CopyFrom(from);
    return *this;
  }
  inline Frame& operator=(Frame&& from) noexcept {
    if (GetArena() == from.GetArena()) {
      if (this != &from) InternalSwap(&from);
    } else {
      CopyFrom(from);
    }
    return *this;
  }

  static const ::PROTOBUF_NAMESPACE_ID::Descriptor* descriptor() {
    return GetDescriptor();
  }
  static const ::PROTOBUF_NAMESPACE_ID::Descriptor* GetDescriptor() {
    return default_instance().GetMetadata().descriptor;
  }
  static const ::PROTOBUF_NAMESPACE_ID::Reflection* GetReflection() {
    return default_instance().GetMetadata().reflection;
  }
  static const Frame& default_instance() {
    return *internal_default_instance();
  }
  static inline const Frame* internal_default_instance() {
    return reinterpret_cast<const Frame*>(
               &_Frame_default_instance_);
  }
  static constexpr int kIndexInFileMessages =
    0;

  friend void swap(Frame& a, Frame& b) {
    a.Swap(&b);
  }
  inline void Swap(Frame* other) {
    if (other == this) return;
    if (GetArena() == other->GetArena()) {
      InternalSwap(other);
    } else {
      ::PROTOBUF_NAMESPACE_ID::internal::GenericSwap(this, other);
    }
  }
  void UnsafeArenaSwap(Frame* other) {
    if (other == this) return;
    GOOGLE_DCHECK(GetArena() == other->GetArena());
    InternalSwap(other);
  }

  // implements Message ----------------------------------------------

  inline Frame* New() const final {
    return CreateMaybeMessage<Frame>(nullptr);
  }

  Frame* New(::PROTOBUF_NAMESPACE_ID::Arena* arena) const final {
    return CreateMaybeMessage<Frame>(arena);
  }
  void CopyFrom(const ::PROTOBUF_NAMESPACE_ID::Message& from) final;
  void MergeFrom(const ::PROTOBUF_NAMESPACE_ID::Message& from) final;
  void CopyFrom(const Frame& from);
  void MergeFrom(const Frame& from);
  PROTOBUF_ATTRIBUTE_REINITIALIZES void Clear() final;
  bool IsInitialized() const final;

  size_t ByteSizeLong() const final;
  const char* _InternalParse(const char* ptr, ::PROTOBUF_NAMESPACE_ID::internal::ParseContext* ctx) final;
  ::PROTOBUF_NAMESPACE_ID::uint8* _InternalSerialize(
      ::PROTOBUF_NAMESPACE_ID::uint8* target, ::PROTOBUF_NAMESPACE_ID::io::EpsCopyOutputStream* stream) const final;
  int GetCachedSize() const final { return _cached_size_.Get(); }

  private:
  inline void SharedCtor();
  inline void SharedDtor();
  void SetCachedSize(int size) const final;
  void InternalSwap(Frame* other);
  friend class ::PROTOBUF_NAMESPACE_ID::internal::AnyMetadata;
  static ::PROTOBUF_NAMESPACE_ID::StringPiece FullMessageName() {
    return "pb_stabilize.Frame";
  }
  protected:
  explicit Frame(::PROTOBUF_NAMESPACE_ID::Arena* arena);
  private:
  static void ArenaDtor(void* object);
  inline void RegisterArenaDtor(::PROTOBUF_NAMESPACE_ID::Arena* arena);
  public:

  ::PROTOBUF_NAMESPACE_ID::Metadata GetMetadata() const final;

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  enum : int {
    kIdFieldNumber = 1,
    kDxFieldNumber = 2,
    kDyFieldNumber = 3,
    kDaFieldNumber = 4,
    kXFieldNumber = 5,
    kYFieldNumber = 6,
    kAFieldNumber = 7,
  };
  // int32 id = 1;
  void clear_id();
  ::PROTOBUF_NAMESPACE_ID::int32 id() const;
  void set_id(::PROTOBUF_NAMESPACE_ID::int32 value);
  private:
  ::PROTOBUF_NAMESPACE_ID::int32 _internal_id() const;
  void _internal_set_id(::PROTOBUF_NAMESPACE_ID::int32 value);
  public:

  // float dx = 2;
  void clear_dx();
  float dx() const;
  void set_dx(float value);
  private:
  float _internal_dx() const;
  void _internal_set_dx(float value);
  public:

  // float dy = 3;
  void clear_dy();
  float dy() const;
  void set_dy(float value);
  private:
  float _internal_dy() const;
  void _internal_set_dy(float value);
  public:

  // float da = 4;
  void clear_da();
  float da() const;
  void set_da(float value);
  private:
  float _internal_da() const;
  void _internal_set_da(float value);
  public:

  // float x = 5;
  void clear_x();
  float x() const;
  void set_x(float value);
  private:
  float _internal_x() const;
  void _internal_set_x(float value);
  public:

  // float y = 6;
  void clear_y();
  float y() const;
  void set_y(float value);
  private:
  float _internal_y() const;
  void _internal_set_y(float value);
  public:

  // float a = 7;
  void clear_a();
  float a() const;
  void set_a(float value);
  private:
  float _internal_a() const;
  void _internal_set_a(float value);
  public:

  // @@protoc_insertion_point(class_scope:pb_stabilize.Frame)
 private:
  class _Internal;

  template <typename T> friend class ::PROTOBUF_NAMESPACE_ID::Arena::InternalHelper;
  typedef void InternalArenaConstructable_;
  typedef void DestructorSkippable_;
  ::PROTOBUF_NAMESPACE_ID::int32 id_;
  float dx_;
  float dy_;
  float da_;
  float x_;
  float y_;
  float a_;
  mutable ::PROTOBUF_NAMESPACE_ID::internal::CachedSize _cached_size_;
  friend struct ::TableStruct_stabilizedata_2eproto;
};
// -------------------------------------------------------------------

class Stabilization PROTOBUF_FINAL :
    public ::PROTOBUF_NAMESPACE_ID::Message /* @@protoc_insertion_point(class_definition:pb_stabilize.Stabilization) */ {
 public:
  inline Stabilization() : Stabilization(nullptr) {}
  ~Stabilization() override;
  explicit constexpr Stabilization(::PROTOBUF_NAMESPACE_ID::internal::ConstantInitialized);

  Stabilization(const Stabilization& from);
  Stabilization(Stabilization&& from) noexcept
    : Stabilization() {
    *this = ::std::move(from);
  }

  inline Stabilization& operator=(const Stabilization& from) {
    CopyFrom(from);
    return *this;
  }
  inline Stabilization& operator=(Stabilization&& from) noexcept {
    if (GetArena() == from.GetArena()) {
      if (this != &from) InternalSwap(&from);
    } else {
      CopyFrom(from);
    }
    return *this;
  }

  static const ::PROTOBUF_NAMESPACE_ID::Descriptor* descriptor() {
    return GetDescriptor();
  }
  static const ::PROTOBUF_NAMESPACE_ID::Descriptor* GetDescriptor() {
    return default_instance().GetMetadata().descriptor;
  }
  static const ::PROTOBUF_NAMESPACE_ID::Reflection* GetReflection() {
    return default_instance().GetMetadata().reflection;
  }
  static const Stabilization& default_instance() {
    return *internal_default_instance();
  }
  static inline const Stabilization* internal_default_instance() {
    return reinterpret_cast<const Stabilization*>(
               &_Stabilization_default_instance_);
  }
  static constexpr int kIndexInFileMessages =
    1;

  friend void swap(Stabilization& a, Stabilization& b) {
    a.Swap(&b);
  }
  inline void Swap(Stabilization* other) {
    if (other == this) return;
    if (GetArena() == other->GetArena()) {
      InternalSwap(other);
    } else {
      ::PROTOBUF_NAMESPACE_ID::internal::GenericSwap(this, other);
    }
  }
  void UnsafeArenaSwap(Stabilization* other) {
    if (other == this) return;
    GOOGLE_DCHECK(GetArena() == other->GetArena());
    InternalSwap(other);
  }

  // implements Message ----------------------------------------------

  inline Stabilization* New() const final {
    return CreateMaybeMessage<Stabilization>(nullptr);
  }

  Stabilization* New(::PROTOBUF_NAMESPACE_ID::Arena* arena) const final {
    return CreateMaybeMessage<Stabilization>(arena);
  }
  void CopyFrom(const ::PROTOBUF_NAMESPACE_ID::Message& from) final;
  void MergeFrom(const ::PROTOBUF_NAMESPACE_ID::Message& from) final;
  void CopyFrom(const Stabilization& from);
  void MergeFrom(const Stabilization& from);
  PROTOBUF_ATTRIBUTE_REINITIALIZES void Clear() final;
  bool IsInitialized() const final;

  size_t ByteSizeLong() const final;
  const char* _InternalParse(const char* ptr, ::PROTOBUF_NAMESPACE_ID::internal::ParseContext* ctx) final;
  ::PROTOBUF_NAMESPACE_ID::uint8* _InternalSerialize(
      ::PROTOBUF_NAMESPACE_ID::uint8* target, ::PROTOBUF_NAMESPACE_ID::io::EpsCopyOutputStream* stream) const final;
  int GetCachedSize() const final { return _cached_size_.Get(); }

  private:
  inline void SharedCtor();
  inline void SharedDtor();
  void SetCachedSize(int size) const final;
  void InternalSwap(Stabilization* other);
  friend class ::PROTOBUF_NAMESPACE_ID::internal::AnyMetadata;
  static ::PROTOBUF_NAMESPACE_ID::StringPiece FullMessageName() {
    return "pb_stabilize.Stabilization";
  }
  protected:
  explicit Stabilization(::PROTOBUF_NAMESPACE_ID::Arena* arena);
  private:
  static void ArenaDtor(void* object);
  inline void RegisterArenaDtor(::PROTOBUF_NAMESPACE_ID::Arena* arena);
  public:

  ::PROTOBUF_NAMESPACE_ID::Metadata GetMetadata() const final;

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  enum : int {
    kFrameFieldNumber = 1,
    kLastUpdatedFieldNumber = 2,
  };
  // repeated .pb_stabilize.Frame frame = 1;
  int frame_size() const;
  private:
  int _internal_frame_size() const;
  public:
  void clear_frame();
  ::pb_stabilize::Frame* mutable_frame(int index);
  ::PROTOBUF_NAMESPACE_ID::RepeatedPtrField< ::pb_stabilize::Frame >*
      mutable_frame();
  private:
  const ::pb_stabilize::Frame& _internal_frame(int index) const;
  ::pb_stabilize::Frame* _internal_add_frame();
  public:
  const ::pb_stabilize::Frame& frame(int index) const;
  ::pb_stabilize::Frame* add_frame();
  const ::PROTOBUF_NAMESPACE_ID::RepeatedPtrField< ::pb_stabilize::Frame >&
      frame() const;

  // .google.protobuf.Timestamp last_updated = 2;
  bool has_last_updated() const;
  private:
  bool _internal_has_last_updated() const;
  public:
  void clear_last_updated();
  const PROTOBUF_NAMESPACE_ID::Timestamp& last_updated() const;
  PROTOBUF_NAMESPACE_ID::Timestamp* release_last_updated();
  PROTOBUF_NAMESPACE_ID::Timestamp* mutable_last_updated();
  void set_allocated_last_updated(PROTOBUF_NAMESPACE_ID::Timestamp* last_updated);
  private:
  const PROTOBUF_NAMESPACE_ID::Timestamp& _internal_last_updated() const;
  PROTOBUF_NAMESPACE_ID::Timestamp* _internal_mutable_last_updated();
  public:
  void unsafe_arena_set_allocated_last_updated(
      PROTOBUF_NAMESPACE_ID::Timestamp* last_updated);
  PROTOBUF_NAMESPACE_ID::Timestamp* unsafe_arena_release_last_updated();

  // @@protoc_insertion_point(class_scope:pb_stabilize.Stabilization)
 private:
  class _Internal;

  template <typename T> friend class ::PROTOBUF_NAMESPACE_ID::Arena::InternalHelper;
  typedef void InternalArenaConstructable_;
  typedef void DestructorSkippable_;
  ::PROTOBUF_NAMESPACE_ID::RepeatedPtrField< ::pb_stabilize::Frame > frame_;
  PROTOBUF_NAMESPACE_ID::Timestamp* last_updated_;
  mutable ::PROTOBUF_NAMESPACE_ID::internal::CachedSize _cached_size_;
  friend struct ::TableStruct_stabilizedata_2eproto;
};
// ===================================================================


// ===================================================================

#ifdef __GNUC__
  #pragma GCC diagnostic push
  #pragma GCC diagnostic ignored "-Wstrict-aliasing"
#endif  // __GNUC__
// Frame

// int32 id = 1;
inline void Frame::clear_id() {
  id_ = 0;
}
inline ::PROTOBUF_NAMESPACE_ID::int32 Frame::_internal_id() const {
  return id_;
}
inline ::PROTOBUF_NAMESPACE_ID::int32 Frame::id() const {
  // @@protoc_insertion_point(field_get:pb_stabilize.Frame.id)
  return _internal_id();
}
inline void Frame::_internal_set_id(::PROTOBUF_NAMESPACE_ID::int32 value) {
  
  id_ = value;
}
inline void Frame::set_id(::PROTOBUF_NAMESPACE_ID::int32 value) {
  _internal_set_id(value);
  // @@protoc_insertion_point(field_set:pb_stabilize.Frame.id)
}

// float dx = 2;
inline void Frame::clear_dx() {
  dx_ = 0;
}
inline float Frame::_internal_dx() const {
  return dx_;
}
inline float Frame::dx() const {
  // @@protoc_insertion_point(field_get:pb_stabilize.Frame.dx)
  return _internal_dx();
}
inline void Frame::_internal_set_dx(float value) {
  
  dx_ = value;
}
inline void Frame::set_dx(float value) {
  _internal_set_dx(value);
  // @@protoc_insertion_point(field_set:pb_stabilize.Frame.dx)
}

// float dy = 3;
inline void Frame::clear_dy() {
  dy_ = 0;
}
inline float Frame::_internal_dy() const {
  return dy_;
}
inline float Frame::dy() const {
  // @@protoc_insertion_point(field_get:pb_stabilize.Frame.dy)
  return _internal_dy();
}
inline void Frame::_internal_set_dy(float value) {
  
  dy_ = value;
}
inline void Frame::set_dy(float value) {
  _internal_set_dy(value);
  // @@protoc_insertion_point(field_set:pb_stabilize.Frame.dy)
}

// float da = 4;
inline void Frame::clear_da() {
  da_ = 0;
}
inline float Frame::_internal_da() const {
  return da_;
}
inline float Frame::da() const {
  // @@protoc_insertion_point(field_get:pb_stabilize.Frame.da)
  return _internal_da();
}
inline void Frame::_internal_set_da(float value) {
  
  da_ = value;
}
inline void Frame::set_da(float value) {
  _internal_set_da(value);
  // @@protoc_insertion_point(field_set:pb_stabilize.Frame.da)
}

// float x = 5;
inline void Frame::clear_x() {
  x_ = 0;
}
inline float Frame::_internal_x() const {
  return x_;
}
inline float Frame::x() const {
  // @@protoc_insertion_point(field_get:pb_stabilize.Frame.x)
  return _internal_x();
}
inline void Frame::_internal_set_x(float value) {
  
  x_ = value;
}
inline void Frame::set_x(float value) {
  _internal_set_x(value);
  // @@protoc_insertion_point(field_set:pb_stabilize.Frame.x)
}

// float y = 6;
inline void Frame::clear_y() {
  y_ = 0;
}
inline float Frame::_internal_y() const {
  return y_;
}
inline float Frame::y() const {
  // @@protoc_insertion_point(field_get:pb_stabilize.Frame.y)
  return _internal_y();
}
inline void Frame::_internal_set_y(float value) {
  
  y_ = value;
}
inline void Frame::set_y(float value) {
  _internal_set_y(value);
  // @@protoc_insertion_point(field_set:pb_stabilize.Frame.y)
}

// float a = 7;
inline void Frame::clear_a() {
  a_ = 0;
}
inline float Frame::_internal_a() const {
  return a_;
}
inline float Frame::a() const {
  // @@protoc_insertion_point(field_get:pb_stabilize.Frame.a)
  return _internal_a();
}
inline void Frame::_internal_set_a(float value) {
  
  a_ = value;
}
inline void Frame::set_a(float value) {
  _internal_set_a(value);
  // @@protoc_insertion_point(field_set:pb_stabilize.Frame.a)
}

// -------------------------------------------------------------------

// Stabilization

// repeated .pb_stabilize.Frame frame = 1;
inline int Stabilization::_internal_frame_size() const {
  return frame_.size();
}
inline int Stabilization::frame_size() const {
  return _internal_frame_size();
}
inline void Stabilization::clear_frame() {
  frame_.Clear();
}
inline ::pb_stabilize::Frame* Stabilization::mutable_frame(int index) {
  // @@protoc_insertion_point(field_mutable:pb_stabilize.Stabilization.frame)
  return frame_.Mutable(index);
}
inline ::PROTOBUF_NAMESPACE_ID::RepeatedPtrField< ::pb_stabilize::Frame >*
Stabilization::mutable_frame() {
  // @@protoc_insertion_point(field_mutable_list:pb_stabilize.Stabilization.frame)
  return &frame_;
}
inline const ::pb_stabilize::Frame& Stabilization::_internal_frame(int index) const {
  return frame_.Get(index);
}
inline const ::pb_stabilize::Frame& Stabilization::frame(int index) const {
  // @@protoc_insertion_point(field_get:pb_stabilize.Stabilization.frame)
  return _internal_frame(index);
}
inline ::pb_stabilize::Frame* Stabilization::_internal_add_frame() {
  return frame_.Add();
}
inline ::pb_stabilize::Frame* Stabilization::add_frame() {
  // @@protoc_insertion_point(field_add:pb_stabilize.Stabilization.frame)
  return _internal_add_frame();
}
inline const ::PROTOBUF_NAMESPACE_ID::RepeatedPtrField< ::pb_stabilize::Frame >&
Stabilization::frame() const {
  // @@protoc_insertion_point(field_list:pb_stabilize.Stabilization.frame)
  return frame_;
}

// .google.protobuf.Timestamp last_updated = 2;
inline bool Stabilization::_internal_has_last_updated() const {
  return this != internal_default_instance() && last_updated_ != nullptr;
}
inline bool Stabilization::has_last_updated() const {
  return _internal_has_last_updated();
}
inline const PROTOBUF_NAMESPACE_ID::Timestamp& Stabilization::_internal_last_updated() const {
  const PROTOBUF_NAMESPACE_ID::Timestamp* p = last_updated_;
  return p != nullptr ? *p : reinterpret_cast<const PROTOBUF_NAMESPACE_ID::Timestamp&>(
      PROTOBUF_NAMESPACE_ID::_Timestamp_default_instance_);
}
inline const PROTOBUF_NAMESPACE_ID::Timestamp& Stabilization::last_updated() const {
  // @@protoc_insertion_point(field_get:pb_stabilize.Stabilization.last_updated)
  return _internal_last_updated();
}
inline void Stabilization::unsafe_arena_set_allocated_last_updated(
    PROTOBUF_NAMESPACE_ID::Timestamp* last_updated) {
  if (GetArena() == nullptr) {
    delete reinterpret_cast<::PROTOBUF_NAMESPACE_ID::MessageLite*>(last_updated_);
  }
  last_updated_ = last_updated;
  if (last_updated) {
    
  } else {
    
  }
  // @@protoc_insertion_point(field_unsafe_arena_set_allocated:pb_stabilize.Stabilization.last_updated)
}
inline PROTOBUF_NAMESPACE_ID::Timestamp* Stabilization::release_last_updated() {
  
  PROTOBUF_NAMESPACE_ID::Timestamp* temp = last_updated_;
  last_updated_ = nullptr;
  if (GetArena() != nullptr) {
    temp = ::PROTOBUF_NAMESPACE_ID::internal::DuplicateIfNonNull(temp);
  }
  return temp;
}
inline PROTOBUF_NAMESPACE_ID::Timestamp* Stabilization::unsafe_arena_release_last_updated() {
  // @@protoc_insertion_point(field_release:pb_stabilize.Stabilization.last_updated)
  
  PROTOBUF_NAMESPACE_ID::Timestamp* temp = last_updated_;
  last_updated_ = nullptr;
  return temp;
}
inline PROTOBUF_NAMESPACE_ID::Timestamp* Stabilization::_internal_mutable_last_updated() {
  
  if (last_updated_ == nullptr) {
    auto* p = CreateMaybeMessage<PROTOBUF_NAMESPACE_ID::Timestamp>(GetArena());
    last_updated_ = p;
  }
  return last_updated_;
}
inline PROTOBUF_NAMESPACE_ID::Timestamp* Stabilization::mutable_last_updated() {
  // @@protoc_insertion_point(field_mutable:pb_stabilize.Stabilization.last_updated)
  return _internal_mutable_last_updated();
}
inline void Stabilization::set_allocated_last_updated(PROTOBUF_NAMESPACE_ID::Timestamp* last_updated) {
  ::PROTOBUF_NAMESPACE_ID::Arena* message_arena = GetArena();
  if (message_arena == nullptr) {
    delete reinterpret_cast< ::PROTOBUF_NAMESPACE_ID::MessageLite*>(last_updated_);
  }
  if (last_updated) {
    ::PROTOBUF_NAMESPACE_ID::Arena* submessage_arena =
      reinterpret_cast<::PROTOBUF_NAMESPACE_ID::MessageLite*>(last_updated)->GetArena();
    if (message_arena != submessage_arena) {
      last_updated = ::PROTOBUF_NAMESPACE_ID::internal::GetOwnedMessage(
          message_arena, last_updated, submessage_arena);
    }
    
  } else {
    
  }
  last_updated_ = last_updated;
  // @@protoc_insertion_point(field_set_allocated:pb_stabilize.Stabilization.last_updated)
}

#ifdef __GNUC__
  #pragma GCC diagnostic pop
#endif  // __GNUC__
// -------------------------------------------------------------------


// @@protoc_insertion_point(namespace_scope)

}  // namespace pb_stabilize

// @@protoc_insertion_point(global_scope)

#include <google/protobuf/port_undef.inc>
#endif  // GOOGLE_PROTOBUF_INCLUDED_GOOGLE_PROTOBUF_INCLUDED_stabilizedata_2eproto
