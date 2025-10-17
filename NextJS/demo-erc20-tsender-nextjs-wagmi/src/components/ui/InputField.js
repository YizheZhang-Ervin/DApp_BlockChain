// 输入表单
export function InputForm({ label, placeholder, value, type, large, onChange }) {
    return (
        <div className="flex flex-col gap-1.5">
            <label className="text-zinc-600 font-medium text-sm">{label}</label>
            {large ? (
                <textarea
                    className={`bg-white py-2 px-3 border border-zinc-300 placeholder:text-zinc-500 text-zinc-900 shadow-xs rounded-lg focus:ring-[4px] focus:ring-zinc-400/15 focus:outline-none h-24 align-text-top`}
                    placeholder={placeholder}
                    value={value || ''}
                    onChange={onChange}
                />
            ) : (
                <input
                    className={`bg-white py-2 px-3 border border-zinc-300 placeholder:text-zinc-500 text-zinc-900 shadow-xs rounded-lg focus:ring-[4px] focus:ring-zinc-400/15 focus:outline-none`}
                    type={type}
                    placeholder={placeholder}
                    value={value || ''}
                    onChange={onChange}
                />
            )}
        </div>
    )
}
