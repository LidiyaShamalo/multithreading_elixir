defmodule Model do
  defmodule Product do
    @type t() :: %__MODULE__{
            id: integer(),
            name: String.t(),
            count: integer(),
            price: integer()
          }

    @enforce_keys [:id, :name, :count, :price]

    defstruct [:id, :name, :count, :price]

    def new(id, name, count, price) do
      %__MODULE__{
        id: id,
        name: name,
        count: count,
        price: price
      }
    end
  end

  defmodule Report do
    @type t() :: %__MODULE__{
            name_product: String.t(),
            count_product: integer()
          }

    @enforce_keys [:name_product, :count_product]
    defstruct [:name_product, :count_product]

    def new(name, count) do
      %__MODULE__{
        name_product: name,
        count_product: count
      }
    end
  end
end
