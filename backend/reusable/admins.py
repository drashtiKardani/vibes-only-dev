class ReadOnlyAdminClass:
    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False


class ReadOnlyAdminDateFields:
    readonly_fields = ("created_at", "updated_at", "deleted_at")


class ReadOnlyContentFields:
    readonly_fields = ReadOnlyAdminDateFields.readonly_fields
